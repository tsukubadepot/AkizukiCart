//
//  NumberFormatterExtension.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/28.
//

import Foundation

extension NumberFormatter {
    func convertToJPY(value: Int) -> String? {
        self.numberStyle = .currencyPlural
        self.locale = Locale(identifier: "ja_JP")
        return self.string(from: value as NSNumber)
    }
}
