//
//  ViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/10.
//

import UIKit
import AlamofireImage

class ViewController: UIViewController {
    var parts: [PartsInfo] = [] {
        didSet {
            displayTotal()
        }
    }
    
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
        
        displayTotal()
    }
    
    func displayTotal() {
        let totalPrice = parts.reduce(0) {
            $0 + $1.price.value * $1.buyCount!
        }
        
        let totalItem = parts.reduce(0) {
            $0 + $1.buyCount!
        }
        countLabel.text = "購入点数： " + String(parts.count) + " 商品　\(totalItem) 点"
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
        
        for (index, item) in parts.enumerated() {
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
        return parts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(parts[indexPath.row].id).appendingPathExtension("jpg")
        cell.productImageView.af.setImage(withURL: imageURL)
        cell.nameLabel.text = parts[indexPath.row].name
        cell.countLabel.text = String(parts[indexPath.row].buyCount!)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
        
        vc.parts = parts[indexPath.row]
        
        present(vc, animated: true, completion: nil)
    }
}
