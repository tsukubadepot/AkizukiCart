//
//  ListTableViewCell.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/12.
//

import UIKit
import AlamofireImage

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView! {
        didSet {
            productImageView.contentMode = .scaleAspectFill
            productImageView.backgroundColor = .systemGray6
            productImageView.layer.borderWidth = 1
            productImageView.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var purchasedImage: UIImageView!
    @IBOutlet weak var place: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        purchasedImage.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(parts: PartsInfo, shopIndex: Int) {
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(parts.id).appendingPathExtension("jpg")
        
        productImageView.af.setImage(withURL: imageURL)
        // 商品ラベルの高さ Constraint は height <= 66 にして上揃えに設定している
        nameLabel.text = parts.name
        countLabel.text = String(parts.buyCount)
        
        backgroundColor = parts.purchased ? .gray : .systemBackground
        productImageView.layer.opacity = parts.purchased ? 0.2 : 1.0
        purchasedImage.isHidden = !(parts.purchased)
        
        accessoryType = .disclosureIndicator
        
        // TODO: - 在庫情報は detailedViewController とリファクタする必要がある
        //
        if shopIndex == 0 {
            if let akihabaraIndex = parts.stores.firstIndex(where: { store -> Bool in
                store.name.contains("秋葉原")
            }) {
                place.text = parts.stores[akihabaraIndex].place
            }
        } else {
            if let yashioIndex = parts.stores.firstIndex(where: { store -> Bool in
                store.name.contains("八潮")
            }) {
                place.text = parts.stores[yashioIndex].place
            }
        }
    }
}
