//
//  HistoryTableViewCell.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/29.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView! {
        didSet {
            productImageView.contentMode = .scaleAspectFill
            productImageView.backgroundColor = .systemGray6
            productImageView.layer.borderWidth = 1
            productImageView.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(parts: PartsInfo) {
        let imageURL = URL(string: "https://akizukidenshi.com/img/goods/L")!.appendingPathComponent(parts.id).appendingPathExtension("jpg")
        
        productImageView.af.setImage(withURL: imageURL)
        nameLabel.text = parts.name
        
        accessoryType = .disclosureIndicator
    }
}
