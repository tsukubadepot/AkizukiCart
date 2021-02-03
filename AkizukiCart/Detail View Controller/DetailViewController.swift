//
//  DetailViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import UIKit
import AlamofireImage

// 個別部品の追加・変更

/// DetailViewController Delegate
protocol DetailViewControllerDelegate: AnyObject {
    /// 商品更新・追加ボタンがタップされた場合
    /// - Parameters:
    ///   - detailedView: 呼び出し元のインスタンス
    ///   - parts: 追加したいパーツの情報
    func didUpdateCartsButtonTapped(_ detailedView: DetailViewController, parts: PartsInfo)
    
    /// 商品更新・追加がキャンセルされた場合
    /// - Parameter detailedView: 呼び出し元のインスタンス
    func didCancelButtonTapped(_ detailedView: DetailViewController)
    
    /// 商品更新・選択ボタンのタイトル名
    /// - Parameter detailedView: 呼び出し元のインスタンス
    func titleOfSelectButton(_ detailedView: DetailViewController) -> String
}

class DetailViewController: UIViewController {
    // MARK: - Local properties
    var parts: PartsInfo!
    let baseURL = "https://akizukidenshi.com/catalog/g/g"

    // MARK: delegate
    weak var delegate: DetailViewControllerDelegate?
    
    // MARK: - UI Parts
    /// 商品名ラベル
    @IBOutlet weak var nameLabel: UILabel!
    /// 価格ラベル
    @IBOutlet weak var priceLabel: UILabel!
    
    /// 商品ページボタン
    @IBOutlet weak var goItemButton: UIButton! {
        didSet {
            goItemButton.layer.cornerRadius = goItemButton.frame.height / 5
        }
    }
    
    /// 商品ラベル
    @IBOutlet weak var partNumberLabel: UILabel!
    /// 通販コードラベル
    @IBOutlet weak var idLabel: UILabel!
    /// 販売日ラベル
    @IBOutlet weak var releaseDateLabel: UILabel!
    /// 製造者ラベル
    @IBOutlet weak var manufacturerLabel: UILabel!
    
    // MARK: - 商品画像
    @IBOutlet weak var productImageView: UIImageView! {
        didSet {
            productImageView.contentMode = .scaleAspectFill
            productImageView.backgroundColor = .systemGray6
            productImageView.layer.borderWidth = 1
            productImageView.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    /// 購入予定数ラベル
    @IBOutlet weak var buyItemCount: UILabel!
    /// 購入予定数変更用ステッパー
    @IBOutlet weak var countStepper: UIStepper! {
        didSet {
            countStepper.stepValue = 1.0
            countStepper.minimumValue = 0.0
            countStepper.maximumValue = 1000.0
        }
    }
    /// 合計金額ラベル
    @IBOutlet weak var totalLabel: UILabel!
    
    /// 秋葉原店商品在庫ラベル
    @IBOutlet weak var akihabaraCountLabel: UILabel!
    /// 秋葉原店売場ラベル
    @IBOutlet weak var akihabaraPlaceLabel: UILabel!
    /// 八潮店商品在庫ラベル
    @IBOutlet weak var yashioCountLabel: UILabel!
    /// 八潮店売場ラベル
    @IBOutlet weak var yashioPlaceLabel: UILabel!
    
    /// キャンセルボタン
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = cancelButton.frame.height / 5
        }
    }
    
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.cornerRadius = addButton.frame.height / 5
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = parts.name
        
        let price = NumberFormatter().convertToJPY(value: parts.price.value) ?? "(価格不明)"
        priceLabel.text = "一個 \(price)"
        partNumberLabel.text = parts.partNumber ?? ""
        idLabel.text = "通販コード:　" + parts.id
        releaseDateLabel.text = "販売日: " + parts.releaseDate
        manufacturerLabel.text = parts.manufacturer
        
        // 在庫情報
        if let akihabaraIndex = parts.stores.firstIndex(where: { store -> Bool in
            store.name.contains("秋葉原")
        }) {
            // TODO: - 在庫店員問い合わせについて
            // TODO: - 在庫情報が取れない時（null)
            akihabaraCountLabel.text = "在庫： \(parts.stores[akihabaraIndex].count ?? 0) 個"
            akihabaraPlaceLabel.text = parts.stores[akihabaraIndex].place
        }
        
        if let yashioIndex = parts.stores.firstIndex(where: { store -> Bool in
            store.name.contains("八潮")
        }) {
            yashioCountLabel.text = "在庫： \(parts.stores[yashioIndex].count ?? 0) 個"
            yashioPlaceLabel.text = parts.stores[yashioIndex].place
        }
        
        // 画像
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(parts.id).appendingPathExtension("jpg")
        productImageView.af.setImage(withURL: imageURL)
        
        updateCountLabel()
        
        // 呼び出し元によって、ボタンの名称を「追加」か「更新」に変更。
        guard let title = delegate?.titleOfSelectButton(self) else {
            // delegate が実装されている限り、ここに到達するかのうせいは低い
            fatalError()
        }

        addButton.setTitle(title, for: .normal)
    }
    
    private func updateCountLabel() {
        //
        buyItemCount.text = "\(parts.buyCount) 点"
        let price = NumberFormatter().convertToJPY(value: parts.price.value * parts.buyCount) ?? "(価格不明)"
        totalLabel.text = "合計 \(price)"
        countStepper.value = Double(parts.buyCount)
    }
    
    @IBAction func goItemButton(_ sender: UIButton) {
        let url = URL(string: baseURL + parts.id)!
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func countStepper(_ sender: UIStepper) {
        parts.buyCount = Int(sender.value)
        
        updateCountLabel()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        delegate?.didCancelButtonTapped(self)
    }
    
    @IBAction func addPartsButton(_ sender: UIButton) {
        delegate?.didUpdateCartsButtonTapped(self, parts: parts)
    }
}
