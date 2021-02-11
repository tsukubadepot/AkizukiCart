//
//  BatchInputViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/02/11.
//

import UIKit
import PKHUD
import Combine
import CombineCocoa

class BatchInputViewController: UIViewController {
    /// 一括入力フィールド
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.layer.borderWidth = 1
            inputTextView.layer.borderColor = UIColor.gray.cgColor
            inputTextView.keyboardDismissMode = .onDrag
        }
    }
    
    /// UITextView 用の ToolBar
    lazy var textViewAccessory: UIToolbar = {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        let clearItem = UIBarButtonItem(title: "全削除", style: .done, target: self, action: #selector(clearButton(_:)))
        
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButton(_:)))
        toolbar.items = [clearItem, spacerItem, doneItem]
        toolbar.sizeToFit()
        
        return toolbar
    }()
    
    @objc func clearButton(_ sender: UIBarButtonItem) {
        inputTextView.text = " "
    }
    
    @objc func doneButton(_ sender: UIBarButtonItem) {
        inputTextView.resignFirstResponder()
    }
    
    
    @IBOutlet weak var progressLabel: UILabel! {
        didSet {
            progressLabel.text = ""
        }
    }
    
    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.progress = 0.0
        }
    }
    
    /// 検索実行
    @IBOutlet weak var searchButton: UIButton! {
        didSet {
            searchButton.layer.cornerRadius = searchButton.frame.height / 5
        }
    }
    
    /// Combine 用の Subscription
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // プロパティオブザーバ内部で設定してはいけない
        inputTextView.inputAccessoryView = textViewAccessory
        
        navigationItem.title = "一括入力"
        
        // TextView の内容に応じてボタンの表示を制御する
        inputTextView.textPublisher
            .compactMap { $0 }
            .sink { text in
                let isItemEmpty = text.isEmpty
                self.searchButton.isEnabled = !isItemEmpty
                self.searchButton.layer.opacity = isItemEmpty ? 0.5 : 1.0
            }
            .store(in: &subscriptions)
        
        // searchButton が押された時（Touch Up Inside）の操作
        searchButton.tapPublisher
            .sink {
                self.searchButtonTapped()
            }
            .store(in: &subscriptions)
    }
    
    // 検索ボタンがタップされた時の処理
    private func searchButtonTapped() {
        let pattern = "[M,K,P,B,R,S,I,C,T]-\\d{5}"
        
        guard let items = self.inputTextView.text.match(pattern) else {
            HUD.flash(.label("有効な通販番号が見つかりませんでした"), delay: 2.0 )
            progressLabel.text = ""
            return
        }
        
        if items.isEmpty {
            HUD.flash(.label("有効な通販番号が見つかりませんでした"), delay: 2.0 )
            progressLabel.text = ""
            return
        }
        
        let searchItemModel = SearchItemModel(items: items)
        searchItemModel.delegate = self
        
        HUD.show(.labeledProgress(title: "検索実行中", subtitle: nil))
        
        searchItemModel.search {
            let result = searchItemModel.getItemsFromSearchResult()
            dump(result)
            HUD.hide { _ in
                HUD.flash(.label("\(result.count)件の商品が見つかりました"), delay: 2.0)
            }
        } errorHandler: { error in
            HUD.hide { _ in
                HUD.flash(.labeledError(title: "通信エラー", subtitle: error.localizedDescription), delay: 2.0)
                self.progressLabel.text = ""
            }
        }
    }
}

extension BatchInputViewController: SearchItemModelDelegate {
    // 検索の実行状況に応じてプログレスバーを変更する
    func searchItemModel(_ searchItemModel: SearchItemModel, progress: Double) {
        progressView.progress = Float(progress)

        let progressText = String(format: "%.0f", progress * 100)
        progressLabel.text = "\(progressText) % 進行中"
    }
}
