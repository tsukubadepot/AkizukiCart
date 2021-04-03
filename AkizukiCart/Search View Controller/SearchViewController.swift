//
//  SearchViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import UIKit
import Alamofire
import PKHUD
import RxSwift
import RxCocoa

// 商品の検索
class SearchViewController: UIViewController {
    // MARK: - Local Properties
    /// Dispose Bag
    private var disposeBag = DisposeBag()
    
    /// View Model
    private var viewModel: SearchViewModelProtocol!

    // MARK: - UI Setup
    /// 一括入力ボタン
    @IBOutlet weak var batchInputButton: UIButton! {
        didSet {
            batchInputButton.layer.cornerRadius = batchInputButton.frame.height / 10
            batchInputButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    
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
    
    // アイテムの選択
    @IBAction func itemSelected(_ sender: UISegmentedControl) {
        let fb = UIImpactFeedbackGenerator(style: .heavy)
        fb.impactOccurred()
    }
    
    // 5桁の数値
    @IBOutlet weak var itemCodeSearchBar: ItemNumberSearchBar! {
        didSet {
            itemCodeSearchBar.keyboardType = .numberPad
            itemCodeSearchBar.placeholder = "5桁の数値を入力"
            itemCodeSearchBar.searchTextField.backgroundColor = causionColor
            itemCodeSearchBar.delegate = self
            itemCodeSearchBar.pastedTextDelegate = self
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
        
        let leftButton = UIBarButtonItem(title: "戻る", style:.plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = leftButton
        //
        itemCodeSearchBar.inputAccessoryView = numPadAccessory
        itemNumberSearchBar.inputAccessoryView = numPadAccessory
                
        // View Model の設定
        setupViewModel()
    }
    
    /// 一括入力ボタン
    @IBAction func batchInputButton(_ sender: UIButton) {
        let batchInputViewController = storyboard?.instantiateViewController(withIdentifier: "batchInputView") as! BatchInputViewController
        
        navigationController?.pushViewController(batchInputViewController, animated: true)
    }
    
    @objc func goBack() {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
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

        // TODO: 最終的には Model に押し込む必要がある
        let model = APIHandler()
        
        model.downloadStateObservable
            .subscribe { state in
                switch state {
                case .loading:
                    HUD.show(.labeledProgress(title: "商品検索中", subtitle: searchItem))
                    
                case .finish(let parts):
                    // パーツボックス内に同じパーツが存在するか否かチェックする
                    let partsbox = PartsBox.shared
                
                    // すでにパーツボックス内にパーツが存在した場合にはエラー表示
                    if partsbox.hasSameParts(newParts: parts) {
                        HUD.hide { _ in
                            HUD.flash(.labeledError(title: "既にパーツボックスに入っています。", subtitle: nil), delay: 2.0)
                        }
                        
                        return
                    }
                    
                    HUD.hide { _ in
                        HUD.flash(.labeledSuccess(title: "見つかりました。", subtitle: parts.name), delay: 2.0)
                    }
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailView") as! DetailViewController
                    
                    vc.parts = parts
                    vc.delegate = self
                    
                    // 購入予定数のパーツ数
                    vc.parts.buyCount = Int(self.itemNumberSearchBar.text ?? "0") ?? 0
                    
                    // 検索履歴に追加する
                    let partsHistory = PartsHistory.shared
                    
                    if !partsHistory.hasSameParts(newParts: parts) {
                        partsHistory.addNewParts(newParts: parts)
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                case .failure(let failure):
                    HUD.hide { _ in
                        HUD.flash(.labeledError(title: "該当する商品はありません", subtitle: failure.id), delay: 2.0)
                    }
                }
            } onError: { error in
                HUD.hide { _ in
                    HUD.flash(.labeledError(title: "エラーが発生しました。", subtitle: error.localizedDescription), delay: 5.0)
                }
                print(error)
            }
            .disposed(by: disposeBag)
        
        model.fetchItem(searchItem + ".json")

    }
}

extension SearchViewController {
    private func setupViewModel() {
        // View Model
        viewModel = SearchViewModel(
            itemCode: itemCodeSearchBar.rx.text.asObservable(),
            itemCount: itemNumberSearchBar.rx.text.asObservable(),
            searchButton: searchButtonTapObservable
        )

        // 通販コードのサーチバーに表示させる文字列
        viewModel.itemCodeTextObservable
            .bind(to: itemCodeSearchBar.rx.text)
            .disposed(by: disposeBag)
        
        // 購入個数に表示させる文字列
        viewModel.itemNumberTextObservable
            .bind(to: itemNumberSearchBar.rx.text)
            .disposed(by: disposeBag)
        
        // 入力バリデーションでエラーがあった場合の HUD 表示
        // Stream で文字列が流れてきた時のみ表示させる
        viewModel.showErrorHUDObservable
            .bind(to: Binder(self) { me, text in
                HUD.flash(.labeledError(title: text, subtitle: nil), delay: 1.0)
                me.itemCodeSearchBar.text = ""
            })
            .disposed(by: disposeBag)
        
        // 通販コードのバリデーションを反映させる
        viewModel.itemCodeTextIsOkObservable
            .bind(to: Binder(self) { me, flag in
                me.itemCodeSearchBar.searchTextField.backgroundColor = flag ? .systemGray5 : me.causionColor
            })
            .disposed(by: disposeBag)
        
        // 購入数のバリデーションを反映させる
        viewModel.itemNumberTextIsOkObservable
            .bind(to: Binder(self) { me, flag in
                me.itemNumberSearchBar.searchTextField.backgroundColor = flag ? .systemGray5 : me.causionColor
            })
            .disposed(by: disposeBag)
        
        // 入力ボタンのバリデーション
        // 購入数とアイテム番号の両方が入力されていた場合に、ボタンを有効にする
        Observable
            .combineLatest(viewModel.itemCodeTextIsOkObservable, viewModel.itemNumberTextIsOkObservable)
            .bind { count, item in
                self.searchButton.isEnabled = count && item
                self.searchButton.layer.opacity = (count && item) ? 1.0 : 0.5
            }
            .disposed(by: disposeBag)
    }
    
    var searchButtonTapObservable: Observable<String> {
        selectedSearchBar?.resignFirstResponder()

        return searchButton
            .rx
            .tap
            .map {
                
                // 先頭文字の取得
                let index = self.itemSegmentedControl.selectedSegmentIndex
                guard let itemID = self.itemSegmentedControl.titleForSegment(at: index) else {
                    fatalError()
                }
                
                return itemID
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
}

extension SearchViewController: ItemNumberSearchBarDelegate {
    func itemNumberSearchBarDidPasteText(_ searchBar: ItemNumberSearchBar, textDidPasted text: String?) {
        guard let text = text else {
            HUD.flash(.labeledError(title: "通販コードが含まれていません。", subtitle: nil), delay: 1.0)
            searchBar.text = ""
            return
        }
        
        // 通販コードを分解する
        let prefix = Character(text.first!.description)
        let number = text.suffix(5).description

        // 万が一アルファベットが規定値以外の場合
        let partNumber = "MKPBRSICT"
        guard let index = partNumber.firstIndex(of: prefix) else {
            return
        }
        
        // 商品番号をコピーする
        itemCodeSearchBar.text = number
        
        // スライダの位置を移動する
        // String.index を partNumber の index に変換する
        itemSegmentedControl.selectedSegmentIndex = index.utf16Offset(in: partNumber)
        
        HUD.flash(.label("通販コードが見つかりました。"), delay: 1.0)
        
    }
}

extension SearchViewController: DetailViewControllerDelegate {
    func didUpdateCartsButtonTapped(_ detailedView: DetailViewController, parts: PartsInfo) {
        let partsBox = PartsBox.shared
        
        partsBox.addNewParts(newParts: parts)
        // Navigation Controller を dismiss
        dismiss(animated: true, completion: nil)
    }
    
    func didCancelButtonTapped(_ detailedView: DetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func titleOfSelectButton(_ detailedView: DetailViewController) -> String {
        return "追加する"
    }
}
