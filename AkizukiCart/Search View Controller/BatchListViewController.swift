//
//  BatchListViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/02/12.
//

import UIKit
import PKHUD
import Combine
import CombineCocoa

class BatchListViewController: UIViewController {
    var items: [PartsInfo]!
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.dataSource = self
            listTableView.delegate = self

            let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
            listTableView.register(nib, forCellReuseIdentifier: "Cell")
        }
    }
    
    @IBOutlet weak var shopSegment: UISegmentedControl!
    
    @IBOutlet weak var selectButton: UIButton! {
        didSet {
            selectButton.layer.cornerRadius = selectButton.frame.height / 5
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = cancelButton.frame.height / 5
        }
    }
    
    // item の変化
    var itemCount:CurrentValueSubject<Int, Never>!
    var subscription = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemCount = CurrentValueSubject<Int, Never>(items.count)
        
        // item 数が変化したらボタンの表示を変更する
        itemCount.sink { value in
            if value == 0 {
                self.selectButton.setTitle("追加できるパーツはありません", for: .normal)
                self.selectButton.isEnabled = false
                self.selectButton.layer.opacity = 0.5
            } else {
                self.selectButton.setTitle("\(value)件のパーツを追加する", for: .normal)
            }
        }
        .store(in: &subscription)
        
        // SegmentedIndex の処理
        shopSegment.selectedSegmentIndexPublisher
            .sink { _ in
                self.listTableView.reloadData()
            }
            .store(in: &subscription)
        
        // ボタンの処理
        selectButton.tapPublisher
            .sink { _ in
                // 押された時の処理
                PartsBox.shared.addNewParts(newPartsArray: self.items)
                // 検索履歴への追加
                self.items.forEach { item in
                    if PartsHistory.shared.hasSameParts(newParts: item) {
                        return
                    }
                    PartsHistory.shared.addNewParts(newParts: item)
                }
                
                HUD.flash(.label("パーツボックスに追加しました"), onView: nil, delay: 2.0) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            .store(in: &subscription)
        
        cancelButton.tapPublisher
            .sink { _ in
                // ダイアログを出してもよいかも
                self.dismiss(animated: true, completion: nil)
            }
            .store(in: &subscription)
        
    }
}

extension BatchListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        
        cell.setup(parts: item, shopIndex: shopSegment.selectedSegmentIndex)
        
        return cell
    }
}

extension BatchListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]

        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        vc.parts = item
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
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let fb = UIImpactFeedbackGenerator(style: .heavy)
            fb.impactOccurred()
            
            // 最新の数値を通知
            itemCount.send(items.count)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let fb = UIImpactFeedbackGenerator(style: .heavy)
        fb.impactOccurred()
        
        // 左スワイプ時に ImpactFeedbackGenerator を使い、Delete は標準を使うため nil を返す
        return nil
    }
}

// パーツ履歴のセルをタップすると、そのパーツに関する情報が DetailViewController で表示される。
// DetailViewController に関する Delegate の処理
extension BatchListViewController: DetailViewControllerDelegate {
    /// パーツ追加のボタンが押された場合
    func didUpdateCartsButtonTapped(_ detailedView: DetailViewController, parts: PartsInfo) {
        guard let index = items.firstIndex(where: { $0.partNumber == parts.partNumber }) else {
            print(#function)
            return
        }
        
        items[index] = parts

        dismiss(animated: true, completion: nil)
        
        return
    }
    
    func didCancelButtonTapped(_ detailedView: DetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func titleOfSelectButton(_ detailedView: DetailViewController) -> String {
        return "数量更新"
    }
}
