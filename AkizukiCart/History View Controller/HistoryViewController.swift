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
    }
    
    @objc func goBack() {
        parent?.dismiss(animated: true, completion: nil)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partsHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryTableViewCell
        
        cell.setup(parts: partsHistory[indexPath.row])
        
        return cell

    }
}

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
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        //vc.parts = partsBox[indexPath.row]
        vc.parts = partsHistory[indexPath.row]
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
            // 自動更新を抑制する
            autoReload = false
            partsHistory.deleteParts(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
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
