//
//  ListTableViewCell.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/12.
//

import UIKit

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        purchasedImage.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
