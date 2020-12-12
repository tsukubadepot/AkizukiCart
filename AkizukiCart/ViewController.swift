//
//  ViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/10.
//

import UIKit
import AlamofireImage

class ViewController: UIViewController {
    var parts: [PartsInfo] = []
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: String(describing: ListTableViewCell.self), bundle: nil)
        listTableView.register(nib, forCellReuseIdentifier: "Cell")
    }

    @IBAction func addPartsButton(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(identifier: "nav")
        
        vc?.modalPresentationStyle = .overFullScreen
        present(vc!, animated: true, completion: nil)
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
        
        return cell
    }
}
