//
//  ViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/10.
//

import UIKit
import AlamofireImage

// メインインタフェース

class ViewController: UIViewController {
    // パーツボックスのインスタンス
    var partsBox = PartxBox.shared
    
    let baseURL = "https://akizukidenshi.com/catalog/cart/cart.aspx"
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.dataSource = self
            listTableView.delegate = self
            listTableView.rowHeight = 82
        }
    }
    
    /// tableView を自動でリロードさせるためのフラグ
    var autoReload = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        listTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        partsBox.updateHandler = {
            self.displayTotal()
            
            // 自動更新させる
            if self.autoReload {
                self.listTableView.reloadData()
            } else {
                self.autoReload = true
            }
        }
        
        displayTotal()
    }
    
    func displayTotal() {
        let totalPrice = partsBox.totalPrice
        let totalItem = partsBox.totalItems
        
        countLabel.text = "購入点数： " + String(partsBox.count) + " 商品　\(totalItem) 点"
        // TODO: 商品価格は整形して表示させる
        totalLabel.text = "合計金額： \(totalPrice) 円"
    }
    
    @IBAction func addPartsButton(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(identifier: "nav")
        
        vc?.modalPresentationStyle = .overFullScreen
        present(vc!, animated: true, completion: nil)
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
                URLQueryItem(name: "qty", value: String(item.buyCount!))
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
        
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(partsBox[indexPath.row].id).appendingPathExtension("jpg")
        
        cell.productImageView.af.setImage(withURL: imageURL)
        // 商品ラベルの高さ Constraint は height <= 66 にして上揃えに設定している
        cell.nameLabel.text = partsBox[indexPath.row].name
        cell.countLabel.text = String(partsBox[indexPath.row].buyCount!)
        
        cell.backgroundColor = partsBox[indexPath.row].purchased! ? .gray : .systemBackground
        cell.purchasedImage.isHidden = !(partsBox[indexPath.row].purchased!)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        vc.parts = partsBox[indexPath.row]
        
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
        }
    }
    
    /// 右スワイプ処理
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action: UIContextualAction
        
        if partsBox[indexPath.row].purchased! {
            action = UIContextualAction(style: .normal, title: "購入取消") { (action, view, handler) in
                self.partsBox.setPurchased(index: indexPath.row, flag: false)
                handler(true)
            }
        } else {
            action = UIContextualAction(style: .normal, title: "購入済み") { (action, view, handler) in
                self.partsBox.setPurchased(index: indexPath.row, flag: true)
                handler(true)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
