//
//  AboutViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/28.
//

import UIKit

class AboutViewController:UIViewController {
    @IBOutlet weak var aboutImageViewController: UIImageView! {
        didSet {
            aboutImageViewController.layer.cornerRadius = aboutImageViewController.bounds.height / 10
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    var columns = [
        ["このアプリケーションについて", "https://www.tsukubadepot.net/archives/750"],
        ["最新バージョンの機能について", "https://www.tsukubadepot.net/archives/829"],
        ["プライバシーポリシー", "https://www.tsukubadepot.net/archives/767"],
        ["お問い合わせ", "https://www.tsukubadepot.net/archives/764"],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem(title: "戻る", style:.plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func goBack() {
        parent?.dismiss(animated: true, completion: nil)
    }
}

extension AboutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)

        cell.textLabel?.text = columns[indexPath.row][0]
        
        return cell
    }
}

extension AboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
                
        let url = URL(string: columns[indexPath.row][1])!
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
