//
//  HistoryViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/29.
//

import UIKit
import PKHUD

class HistoryViewController: UIViewController {
    var partsHistory = PartsHistory.shared
    var partsBox = PartsBox.shared

    /// 登録されたパーツ履歴を、通板番号のアルファベット別に辞書として再登録する
    var sortedPartsHistory: [String:[PartsInfo]] = [:]

    private func getSortedPartsHistory() -> [String:[PartsInfo]] {
        return Dictionary(grouping: partsHistory) { item in
            return String(item.id.first!)
        }
    }

    /// 通販番号アルファベットのうち、履歴にあるものだけ選択し、ソートする
    var selectedSectionLabel: [String] {
        return sortedPartsHistory.keys.sorted()
    }
    
    var secTable = [
        "B":"バッテリー関連", "C":"コネクタ関連", "I":"集積回路・半導体関連",
        "K":"キット関連", "M":"モジュール・電源・測定器関連", "P":"パーツ一般",
        "R":"抵抗関連", "S":"ストレージ関連", "T":"ツール関連"
    ]
    
    @IBOutlet weak var historyTableView: UITableView! {
        didSet {
            historyTableView.dataSource = self
            historyTableView.delegate = self
        }
    }
    
    /// tableView を自動でリロードさせるためのフラグ
    var autoReload = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: String(describing: HistoryTableViewCell.self), bundle: nil)
        historyTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        partsHistory.updateDelegate = self
        
        let leftButton = UIBarButtonItem(title: "戻る", style:.plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = leftButton
        
        sortedPartsHistory = getSortedPartsHistory()
    }
    
    @objc func goBack() {
        parent?.dismiss(animated: true, completion: nil)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // 検索履歴に登録された通販番号のアルファベットの数（= keys）の数を返す
        return sortedPartsHistory.keys.count
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // セクションに該当するアルファベットの選択
        let index = selectedSectionLabel[section]
        
        // アルファベットに対応する部品分類の選択
        guard let headerName = secTable[index] else {
            return nil
        }
        
        return index + ":" + headerName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // キー別（アルファベット別）に登録数を返す。optional 対策としてキーが存在しない場合には空配列を返す
        return sortedPartsHistory[selectedSectionLabel[section], default: []].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryTableViewCell
        
        // 呼び出されたセクションに該当するパーツが存在しない場合は、デフォルトの UITableView を返す
        let label = selectedSectionLabel[indexPath.section]
        
        guard let partsInSection = sortedPartsHistory[label] else {
            return UITableViewCell()
        }
        
        cell.setup(parts: partsInSection[indexPath.row])
        
        return cell

    }
}

// パーツ履歴のセルをタップすると、そのパーツに関する情報が DetailViewController で表示される。
// DetailViewController に関する Delegate の処理
extension HistoryViewController: DetailViewControllerDelegate {
    /// パーツ追加のボタンが押された場合
    func didUpdateCartsButtonTapped(_ detailedView: DetailViewController, parts: PartsInfo) {
        if partsBox.hasSameParts(newParts: parts) {
            HUD.flash(.label("既にパーツボックスに入っています"), delay: 2.0)
        } else {
            let alertController = UIAlertController(title: "パーツの追加", message: "選択したパーツを追加しますか", preferredStyle: .alert)
            let doAction = UIAlertAction(title: "追加する", style: .destructive) { _ in
                
                self.partsBox.addNewParts(newParts: parts)
                
                HUD.flash(.labeledSuccess(title: "追加しました。", subtitle: parts.name), delay: 2.0) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            
            alertController.addAction(doAction)
            alertController.addAction(cancelAction)
            
            detailedView.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didCancelButtonTapped(_ detailedView: DetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func titleOfSelectButton(_ detailedView: DetailViewController) -> String {
        return "商品追加"
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 呼び出されたセクションに該当するパーツが存在しない場合は早期リターン
        let label = selectedSectionLabel[indexPath.section]
        
        guard let partsInSection = sortedPartsHistory[label] else {
            return
        }

        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        vc.parts = partsInSection[indexPath.row]
        vc.delegate = self
        
        present(vc, animated: true, completion: nil)
    }
    
    /// 編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /// セルの削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedTable = selectedSectionLabel[indexPath.section]
            guard let selectedPartsInSection = sortedPartsHistory[selectedTable] else {
                return
            }
            
            // 自動更新を抑制する
            autoReload = false
            partsHistory.deleteParts(deleteParts: selectedPartsInSection[indexPath.row])
            // ソートしなおす
            sortedPartsHistory = getSortedPartsHistory()

            // MARK: セクション内のセルが 0 になる時には、そのセクションも消さなければならない
            // UITableView をセクション表示している場合には、そのセクションの最後のセルを消す場合にはセクションごと消去する必要がある
            if sortedPartsHistory[selectedTable, default: []].count == 0 {
                let indexSet = NSIndexSet(index: indexPath.section)
                tableView.deleteSections(indexSet as IndexSet, with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            let fb = UIImpactFeedbackGenerator(style: .heavy)
            fb.impactOccurred()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let fb = UIImpactFeedbackGenerator(style: .heavy)
        fb.impactOccurred()
        
        // 左スワイプ時に ImpactFeedbackGenerator を使い、Delete は標準を使うため nil を返す
        return nil
    }
}

extension HistoryViewController: PartsBoxDelegate {
    func updateHandler() {
        // 自動更新させる
        if autoReload {
            historyTableView.reloadData()
        } else {
            autoReload = true
        }
    }
}
