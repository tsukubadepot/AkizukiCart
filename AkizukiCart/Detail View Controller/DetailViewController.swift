//
//  DetailViewController.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import UIKit
import AlamofireImage

// 個別部品の追加・変更

class DetailViewController: UIViewController {
    // MARK: - Local properties
    var parts: PartsInfo!
    let baseURL = "https://akizukidenshi.com/catalog/g/g"
    
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
        priceLabel.text = "一個 \(parts.price.value) 円"
        partNumberLabel.text = parts.partNumber ?? ""
        idLabel.text = "通販コード:　" + parts.id
        releaseDateLabel.text = "販売日: " + parts.releaseDate
        manufacturerLabel.text = parts.manufacturer
        
        // 在庫情報
        if let akihabaraIndex = parts.stores.firstIndex(where: { store -> Bool in
            store.name.contains("秋葉原")
        }) {
            // TODO: - 在庫店員問い合わせについて
            akihabaraCountLabel.text = "在庫： \(parts.stores[akihabaraIndex].count) 個"
            akihabaraPlaceLabel.text = parts.stores[akihabaraIndex].place
        }
        
        if let yashioIndex = parts.stores.firstIndex(where: { store -> Bool in
            store.name.contains("八潮")
        }) {
            yashioCountLabel.text = "在庫： \(parts.stores[yashioIndex].count) 個"
            yashioPlaceLabel.text = parts.stores[yashioIndex].place
        }
        
        // 画像
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(parts.id).appendingPathExtension("jpg")
        productImageView.af.setImage(withURL: imageURL)
        
        updateCountLabel()
        
        // 呼び出し元によって、ボタンの名称を「追加」か「更新」に変更。
        if parent is UINavigationController {
            addButton.setTitle("追加する", for: .normal)
        } else {
            addButton.setTitle("更新する", for: .normal)
        }
    }
    
    private func updateCountLabel() {
        //
        buyItemCount.text = "\(parts.buyCount!) 点"
        // TODO: curreny の処理
        totalLabel.text = "合計 \(parts.buyCount! * parts.price.value) 円"
        countStepper.value = Double(parts.buyCount!)
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
        if parent is UINavigationController {
            parent?.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addPartsButton(_ sender: UIButton) {
        let partsbox = PartxBox.shared
        
        // 呼び出し元に応じて処理を変更する
        if self.parent is UINavigationController {
            // 新しく部品を追加する
            // TODO: - すでに同じ部品が入っているときの処理 -> 検索段階で処理させる
            partsbox.addNewParts(newParts: parts)
            
            parent?.dismiss(animated: true, completion: nil)
        } else {
            // パーツ数がゼロの場合、削除するか
            if parts.buyCount == 0 {
                let deleteItem = UIAlertAction(title: "削除する", style: .destructive) { _ in
                    partsbox.deleteParts(deleteParts: self.parts)
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelItem = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                    return
                }
                
                let alertAction = UIAlertController(title: "パーツの削除", message: "パーツボックスから削除しますか？", preferredStyle: .alert)
                
                alertAction.addAction(deleteItem)
                alertAction.addAction(cancelItem)
                
                present(alertAction, animated: true, completion: nil)
            } else {
                
                partsbox.updateParts(updateParts: parts)
                
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
