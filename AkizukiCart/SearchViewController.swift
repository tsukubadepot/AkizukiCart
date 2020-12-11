//
//  SearchViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import UIKit
import Alamofire
import PKHUD

class SearchViewController: UIViewController {
    @IBOutlet weak var itemSegmentedControl: UISegmentedControl! {
        didSet {
            // color literal
            itemSegmentedControl.selectedSegmentTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        }
    }
    
    /// 現在選択されているサーチバー
    var selectedSearchBar: UISearchBar?
    
    /// 現時点で入力されている文字列
    var currentText: String?
    
    /// 注意促進用の背景色
    var causionColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
    
    // 5桁の数値
    @IBOutlet weak var itemCodeSearchBar: UISearchBar! {
        didSet {
            itemCodeSearchBar.keyboardType = .numberPad
            itemCodeSearchBar.placeholder = "5桁の数値を入力"
            itemCodeSearchBar.searchTextField.backgroundColor = causionColor
            itemCodeSearchBar.delegate = self
        }
    }
    
    // 購入数
    @IBOutlet weak var itemNumberSearchBar: UISearchBar!{
        didSet {
            itemNumberSearchBar.keyboardType = .numberPad
            itemNumberSearchBar.placeholder = "購入数を入力"
            itemNumberSearchBar.searchTextField.backgroundColor = causionColor
            itemNumberSearchBar.delegate = self
        }
    }
    
    // MARK: - UIToolbar for Numeric Pad
    /// テンキー用の ToolBar
    lazy var numPadAccessory: UIToolbar = {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancelButton(_:)))
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButton(_:)))
        toolbar.items = [cancelItem, spacerItem, doneItem]
        toolbar.sizeToFit()
        
        return toolbar
    }()
    
    /// cancel button
    @objc func cancelButton(_ sender: UIBarButtonItem){
        guard let selectedSearchBar = selectedSearchBar else {
            return
        }
        
        selectedSearchBar.text? = currentText ?? ""
        
        switch selectedSearchBar {
        case itemCodeSearchBar:
            validateCodeCount(selectedSearchBar)

        case itemNumberSearchBar:
            validateItemCount(selectedSearchBar, count: 0)
        
        default:
            fatalError()
        }
        
        closeKeyboard()
    }
    
    /// done button
    @objc func doneButton(_ sender: UIBarButtonItem) {
        closeKeyboard()
    }
    
    private func closeKeyboard() {
        selectedSearchBar?.resignFirstResponder()
        selectedSearchBar = nil
    }
    
    /// 検索ボタンの設定
    @IBOutlet weak var searchButton: UIButton! {
        didSet {
            searchButton.layer.cornerRadius = searchButton.frame.height / 5
        }
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        itemCodeSearchBar.inputAccessoryView = numPadAccessory
        itemNumberSearchBar.inputAccessoryView = numPadAccessory
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        // TODO: - 検索前にバリデーションする必要がある。場合によってはボタンを使えなくするなど。
        
        selectedSearchBar?.resignFirstResponder()
        
        // 先頭文字の取得
        let index = itemSegmentedControl.selectedSegmentIndex
        guard let itemID = itemSegmentedControl.titleForSegment(at: index) else {
            fatalError()
        }
        
        guard let itemCode = itemCodeSearchBar.text,
              itemCode.count == 5 else {
            print(itemCodeSearchBar.text!)
            print("not enough number")
            return
        }
        
        let searchItem = "\(itemID)-\(itemCode)"

        HUD.show(.labeledProgress(title: "商品検索中", subtitle: searchItem))
        
        APIHandler.searchItems(searchItem + ".json") { parts in
            HUD.hide { _ in
                HUD.flash(.labeledSuccess(title: "見つかりました。", subtitle: parts.name), delay: 2.0)
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
            
            vc.parts = parts
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } notfoundHandler: { failer in
            HUD.hide { _ in
                HUD.flash(.labeledError(title: "該当する商品はありません", subtitle: failer.id), delay: 2.0)
            }
        } errorHadler: { error in
            // TODO: - reachability のチェック方法は検討が必要。エラー原因を詳細に検討する必要がある。
            HUD.hide { _ in
                HUD.flash(.labeledError(title: "エラーが発生しました。", subtitle: error.localizedDescription), delay: 5.0)
            }
            print(error)
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    /// 選択された SearchBar と現時点でのテキストを保存しておく
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        selectedSearchBar = searchBar
        currentText = searchBar.text
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchBar {
        // アイテム番号の入力チェック
        case itemCodeSearchBar:
            // 最大5桁の数値
            searchBar.text = String(searchText.prefix(5))
            validateCodeCount(searchBar)
            
        // アイテム個数のチェック
        case itemNumberSearchBar:
            if searchText.count > 0 && searchText.first == "0" {
                searchBar.text = String(searchText.dropFirst())
            }
            
            validateItemCount(searchBar, count: 0)
        
        default:
            fatalError()
        }
    }
    
    /// 入力文字数の確認
    private func validateCodeCount(_ searchBar: UISearchBar) {
        // 入力数値数が足りない場合には、背景色を赤くする
        if searchBar.text?.count != 5 {
            searchBar.searchTextField.backgroundColor = causionColor
        } else {
            searchBar.searchTextField.backgroundColor = .systemGray5
        }
    }
    
    /// 入力文字数の確認
    private func validateItemCount(_ searchBar: UISearchBar, count: Int) {
        if searchBar.text?.count == count {
            searchBar.searchTextField.backgroundColor = causionColor
        } else {
            searchBar.searchTextField.backgroundColor = .systemGray5
        }
    }
}
