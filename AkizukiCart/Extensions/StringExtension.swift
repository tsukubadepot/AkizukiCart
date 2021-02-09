//
//  StringExtension.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/02/06.
//

import Foundation

extension String {
    // https://zenn.dev/kyome/articles/1a55547614dd495a869d
    // http://iwakwak.hatenablog.com/entry/2019/11/13/191142
    // オリジナルはマッチしない、あるいは error の場合には [] を返していたが、nil に変更
    /// 正規表現にマッチした文字列を得る
    /// - Parameter pattern: 正規表現
    /// - Returns: マッチした文字列の配列。マッチしなかった場合には nil
    func match(_ pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        return regex.matches(in: self, range: NSRange(location: 0, length: self.count)).map { String(self[Range($0.range, in:self)!]) }
    }
}
