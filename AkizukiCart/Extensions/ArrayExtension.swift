//
//  ArrayExtension.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/02/11.
//

import Foundation

//https://gist.github.com/sumitokamoi/22b8f30c2c1a3ef93cb1f03d4a7e8066
extension Array {
    /// 配列を指定された chunkSize ごとに分割する
    /// - Parameter chunkSize: 一かたまりのサイズ
    /// - Returns: 分割された二次元配列
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

