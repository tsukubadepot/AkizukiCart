//
//  ItemNumberSearchBar.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/02/06.
//

import UIKit

protocol ItemNumberSearchBarDelegate: AnyObject {
    func itemNumberSearchBarDidPasteText(_ searchBar: ItemNumberSearchBar, textDidPasted text: String?)
}

class ItemNumberSearchBar: UISearchBar {
    weak var pastedTextDelegate: ItemNumberSearchBarDelegate?
    
    private func setuUpPopupMenu() {
        let menuController = UIMenuController.shared
        let menuItem = UIMenuItem(title: "商品番号をコピー", action: #selector(onMenu1(sender:)))
        
        // MenuControllerにMenuItemを追加.
        menuController.menuItems = [menuItem]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setuUpPopupMenu()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setuUpPopupMenu()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onMenu1(sender:)) {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    @objc private func onMenu1(sender: UIMenuItem) {        
        if UIPasteboard.general.hasStrings,
           let text = UIPasteboard.general.string {
            let pattern = "[M,K,P,B,R,S,I,C,T]-\\d{5}"
            
            let hitted = text.match(pattern)
            pastedTextDelegate?.itemNumberSearchBarDidPasteText(self, textDidPasted: hitted?.first)
        }
    }
}
