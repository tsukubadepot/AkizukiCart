//
//  Parts.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/23.
//
import Foundation

// PartsBox class
// Singleton として実装

final class PartxBox {
    static var shared = PartxBox()
    
    private init () {}
    
    private var parts: [PartsInfo] = [] {
        didSet {
            // パーツ数が増えたかどうかをフラグとして渡す
            updateHandler?(parts.count > oldValue.count)
        }
    }
    
    /// パーツボックス内のパーツ数
    var count: Int {
        parts.count
    }
    
    /// パーツボックス内の合計金額
    var totalPrice: Int {
        parts.reduce(0) {
            $0 + $1.price.value * $1.buyCount!
        }
    }
    
    /// パーツボックス内の合計商品数
    var totalItems: Int {
        parts.reduce(0) {
            $0 + $1.buyCount!
        }
    }
    
    /// パーツを更新した時に実行させたい処理
    var updateHandler: ((Bool) -> ())?
    
    /// 同じ品番のパーツを持っているかチェック
    /// - Parameter newParts: 追加したいパーツ
    /// - Returns: すでにパーツボックスに存在する場合には true。存在しない場合には false
    func hasSameParts(newParts: PartsInfo) -> Bool {
        parts.contains(where: { $0.partNumber == newParts.partNumber })
    }
    
    /// パーツの追加。
    /// - Parameter newParts: 追加したいパーツ
    func addNewParts(newParts: PartsInfo) {
        parts.append(newParts)
    }
    
    /// パーツの削除
    /// - Parameter deleteParts: 削除したいパーツ
    func deleteParts(deleteParts: PartsInfo) {
        parts.removeAll { $0.partNumber == deleteParts.partNumber }
    }
    
    /// パーツの削除
    /// - Parameter index: インデックス
    func deleteParts(index: Int) {
        parts.remove(at: index)
    }
    
    /// パーツボックスの更新
    /// - Parameter updateParts: 追加するパーツ
    /// - Returns: false: 更新すべきパーツが存在しない場合, true: 更新に成功した場合
    @discardableResult
    func updateParts(updateParts: PartsInfo) -> Bool {
        guard let index = parts.firstIndex(where: { $0.partNumber == updateParts.partNumber }) else {
            return false
        }
        
        parts[index] = updateParts
        
        return true
    }
    
    // enumerated
    func enumerated() -> EnumeratedSequence<[PartsInfo]> {
        parts.enumerated()
    }
    
    // subscript
    subscript(_ index: Int) -> PartsInfo {
        return parts[index]
    }
}
