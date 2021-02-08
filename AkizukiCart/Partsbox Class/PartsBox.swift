//
//  Parts.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/23.
//
import Foundation

// PartsBox class
// Singleton として実装

protocol PartsBoxDelegate: AnyObject {
    func updateHandler()
}

final class PartsBox: PartsBoxBase {
    static let shared = PartsBox()
    
    private init() {
        super.init(key: "parts")
    }
}

final class PartsHistory: PartsBoxBase {
    static let shared = PartsHistory()
    
    private init() {
        super.init(key: "history")
    }
    
}

class PartsBoxBase {
    // just for IteratorProtocol
    private var currentIndex = 0
    
    private var key:String
    
    init (key:String) {
        self.key = key
    }
    
    // Delegate
    weak var updateDelegate: PartsBoxDelegate?
    
    private var parts: [PartsInfo]  {
        get {
            UserDefaults.standard.decodedObject([PartsInfo].self, forKey: key) ?? []
        }
        
        set {
            UserDefaults.standard.setEncoded(newValue, forKey: key)
            
            updateDelegate?.updateHandler()
        }
    }

    /// パーツボックス内のパーツ数
    var count: Int {
        parts.count
    }
    
    /// パーツボックス内の合計金額
    var totalPrice: Int {
        parts.reduce(0) {
            $0 + $1.price.value * $1.buyCount
        }
    }
    
    /// パーツボックス内の合計商品数
    var totalItems: Int {
        parts.reduce(0) {
            $0 + $1.buyCount
        }
    }
    
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
    
    func setPurchased(index: Int, flag: Bool) {
        parts[index].purchased = flag
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
}

extension PartsBoxBase: IteratorProtocol {
    func next() -> PartsInfo? {
        defer {
            currentIndex += 1
        }
        
        if currentIndex >= count {
           return nil
        } else {
            return parts[currentIndex]
        }
    }
}

extension PartsBoxBase: Collection, Sequence {
    // Protocol Collection
    typealias Element = PartsInfo
    typealias Index = Int
    
    func index(after i: Index) -> Index {
        return i + 1
    }
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        return parts.count
    }
    
    subscript(position: Index) -> PartsInfo {
        return parts[position]
    }
}
