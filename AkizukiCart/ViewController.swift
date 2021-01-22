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
    var partxbox = PartxBox.shared
    
    let baseURL = "https://akizukidenshi.com/catalog/cart/cart.aspx"
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.dataSource = self
            listTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        listTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        partxbox.updateHandler = { addflag in
            self.displayTotal()
            
            // パーツ数が増えた時だけリロード
            // 削除時は逐次アニメーションさせる
            if addflag {
                self.listTableView.reloadData()
            }
        }
        
        displayTotal()
    }
    
    func displayTotal() {
        let totalPrice = partxbox.totalPrice
        let totalItem = partxbox.totalItems
        
        countLabel.text = "購入点数： " + String(partxbox.count) + " 商品　\(totalItem) 点"
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
        
        for (index, item) in partxbox.enumerated() {
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
        return partxbox.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(partxbox[indexPath.row].id).appendingPathExtension("jpg")
        
        cell.productImageView.af.setImage(withURL: imageURL)
        cell.nameLabel.text = partxbox[indexPath.row].name
        cell.countLabel.text = String(partxbox[indexPath.row].buyCount!)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        vc.parts = partxbox[indexPath.row]
        
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            partxbox.deleteParts(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
