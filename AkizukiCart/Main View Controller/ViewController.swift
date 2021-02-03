//
//  ViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/10.
//

import UIKit

// メインインタフェース

class ViewController: UIViewController {
    // パーツボックスのインスタンス
    var partsBox = PartsBox.shared
    
    let baseURL = "https://akizukidenshi.com/catalog/cart/cart.aspx"
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var shopSegment: UISegmentedControl!
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.dataSource = self
            listTableView.delegate = self
            //listTableView.rowHeight = 111//82
        }
    }
    
    /// tableView を自動でリロードさせるためのフラグ
    var autoReload = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        listTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        partsBox.updateDelegate = self
        
        displayTotal()
    }
    
    func displayTotal() {
        let totalItem = partsBox.totalItems        
        countLabel.text = "購入点数： " + String(partsBox.count) + " 商品　\(totalItem) 点"

        let totalPrice = NumberFormatter().convertToJPY(value: partsBox.totalPrice) ?? "(価格不明)"
        totalLabel.text = "合計金額： \(totalPrice)"
    }
    
    @IBAction func shopPlaceSegment(_ sender: UISegmentedControl) {
        listTableView.reloadData()
    }
    
    @IBAction func addPartsButton(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "nav") else {
            fatalError(#function)
        }
        
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func historyButton(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "history") else {
            fatalError(#function)
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addCartButton(_ sender: UIBarButtonItem) {
        var urlComponents = URLComponents(string: baseURL)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "quick", value: "True")
        ]
        
        for (index, item) in partsBox.enumerated() {
            urlComponents.queryItems?.append(contentsOf: [
                URLQueryItem(name: "class1_\(index + 1)", value: String(item.id.prefix(1))),
                URLQueryItem(name: "goods", value: String(item.id.suffix(5))),
                URLQueryItem(name: "qty", value: String(item.buyCount))
            ])
        }
        
        let url = try! urlComponents.asURL()
        print(url.description)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partsBox.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        
        cell.setup(parts: partsBox[indexPath.row], shopIndex: shopSegment.selectedSegmentIndex)
                
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        vc.parts = partsBox[indexPath.row]
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
            partsBox.deleteParts(index: indexPath.row)
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
    
    /// 右スワイプ処理
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action: UIContextualAction
        
        let fb = UIImpactFeedbackGenerator(style: .heavy)
        fb.impactOccurred()
        
        if partsBox[indexPath.row].purchased {
            action = UIContextualAction(style: .normal, title: "購入取消") { (action, view, handler) in
                self.partsBox.setPurchased(index: indexPath.row, flag: false)
                
                let fb = UIImpactFeedbackGenerator(style: .heavy)
                fb.impactOccurred()

                handler(true)
            }
        } else {
            action = UIContextualAction(style: .normal, title: "購入済み") { (action, view, handler) in
                self.partsBox.setPurchased(index: indexPath.row, flag: true)
                
                let fb = UIImpactFeedbackGenerator(style: .heavy)
                fb.impactOccurred()

                handler(true)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ViewController: PartsBoxDelegate {
    func updateHandler() {
        self.displayTotal()
        
        // 自動更新させる
        if self.autoReload {
            self.listTableView.reloadData()
        } else {
            self.autoReload = true
        }
    }
}

extension ViewController: DetailViewControllerDelegate {
    func didUpdateCartsButtonTapped(_ detailedView: DetailViewController, parts: PartsInfo) {
        // パーツ数がゼロの場合、削除するか
        if parts.buyCount == 0 {
            let deleteItem = UIAlertAction(title: "削除する", style: .destructive) { _ in
                self.partsBox.deleteParts(deleteParts: parts)
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelItem = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                return
            }
            
            let alertAction = UIAlertController(title: "パーツの削除", message: "パーツボックスから削除しますか？", preferredStyle: .alert)
            
            alertAction.addAction(deleteItem)
            alertAction.addAction(cancelItem)

            // alertAction は detailedView 上に表示させる
            detailedView.present(alertAction, animated: true, completion: nil)
        } else {
            
            partsBox.updateParts(updateParts: parts)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didCancelButtonTapped(_ detailedView: DetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func titleOfSelectButton(_ detailedView: DetailViewController) -> String {
        return "更新する"
    }
}
