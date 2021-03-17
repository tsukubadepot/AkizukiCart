//
//  Parts.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/23.
//
import Foundation

// PartsBox class
// Singleton として実装

//protocol PartsBoxDelegate: AnyObject {
//    func updateHandler()
//}
//
//final class PartsBox: PartsBoxBase {
//    static let shared = PartsBox()
//    
//    private init() {
//        super.init(key: "parts")
//    }
//}
//
//final class PartsHistory: PartsBoxBase {
//    static let shared = PartsHistory()
//    
//    private init() {
//        super.init(key: "history")
//    }
//
//}
//
//class TestPartsBoxBase: Sequence, IteratorProtocol {
//    // Iterator Protocol で使う現在のインデックス
//    private var currentIndex = 0
//    typealias Element = PartsInfo
//    
//    // UserDefaults で使う保存用の Key
//    private var key:String
//    
//    init (key:String) {
//        self.key = key
//    }
//    
//    // Delegate
//    weak var updateDelegate: PartsBoxDelegate?
//
//    // ここのパーツ情報
//    private var parts: [PartsInfo] {
//        get {
//            UserDefaults.standard.decodedObject([PartsInfo].self, forKey: key) ?? []
//        }
//
//        set {
//            UserDefaults.standard.setEncoded(newValue, forKey: key)
//
//            updateDelegate?.updateHandler()
//        }
//    }
//    
//    // required method for IteratorProtocol
//    func next() -> Element? {
//        defer {
//            currentIndex += 1
//        }
//        
//        if currentIndex >= count {
//            return nil
//        } else {
//            return parts[currentIndex]
//        }
//    }
//    
//    func append(_ newElement: PartsInfo) {
//        parts.append(newElement)
//    }
//    
//    func append(contentsOf: [PartsInfo]){
//        parts.append(contentsOf: contentsOf)
//    }
//}
//
//extension TestPartsBoxBase: Collection {
//    typealias Index = Int
//    
//    var startIndex: Index {
//        0
//    }
//    
//    var endIndex: Index {
//        parts.count
//    }
//    
//    func index(after i: Index) -> Index {
//        i + 1
//    }
//    
//    subscript(position: Index) -> Element {
//        parts[position]
//    }
//}
//
//class PartsBoxBase {
//    typealias Element = PartsInfo
//    typealias Index = Int
//
//    // just for IteratorProtocol
//    private var currentIndex = 0
//
//    private var key:String
//
//    init (key:String) {
//        self.key = key
//    }
//
//    // Delegate
//    weak var updateDelegate: PartsBoxDelegate?
//
//    private var parts: [PartsInfo]  {
//        get {
//            UserDefaults.standard.decodedObject([PartsInfo].self, forKey: key) ?? []
//        }
//
//        set {
//            UserDefaults.standard.setEncoded(newValue, forKey: key)
//
//            updateDelegate?.updateHandler()
//        }
//    }
//
//    /// パーツボックス内の合計金額
//    var totalPrice: Int {
//        parts.reduce(0) {
//            $0 + $1.price.value * $1.buyCount
//        }
//    }
//
//    /// パーツボックス内の合計商品数
//    var totalItems: Int {
//        parts.reduce(0) {
//            $0 + $1.buyCount
//        }
//    }
//
//    /// 同じ品番のパーツを持っているかチェック
//    /// - Parameter newParts: 追加したいパーツ
//    /// - Returns: すでにパーツボックスに存在する場合には true。存在しない場合には false
//    func hasSameParts(newParts: PartsInfo) -> Bool {
//        parts.contains(where: { $0.partNumber == newParts.partNumber })
//    }
//
//    /// パーツの追加。
//    /// - Parameter newParts: 追加したいパーツ
//    func addNewParts(newParts: PartsInfo) {
//        parts.append(newParts)
//    }
//
//    /// 複数パーツの追加。
//    /// - Parameter newPartsArray: 追加したいパーツの配列
//    func addNewParts(newPartsArray: [PartsInfo]) {
//        parts.append(contentsOf: newPartsArray)
//    }
//
//    /// パーツの削除
//    /// - Parameter deleteParts: 削除したいパーツ
//    func deleteParts(deleteParts: PartsInfo) {
//        parts.removeAll { $0.partNumber == deleteParts.partNumber }
//    }
//
//    /// パーツの削除
//    /// - Parameter index: インデックス
//    func deleteParts(index: Int) {
//        parts.remove(at: index)
//    }
//
//    func setPurchased(index: Int, flag: Bool) {
//        parts[index].purchased = flag
//    }
//
//    /// パーツボックスの更新
//    /// - Parameter updateParts: 追加するパーツ
//    /// - Returns: false: 更新すべきパーツが存在しない場合, true: 更新に成功した場合
//    @discardableResult
//    func updateParts(updateParts: PartsInfo) -> Bool {
//        guard let index = parts.firstIndex(where: { $0.partNumber == updateParts.partNumber }) else {
//            return false
//        }
//
//        parts[index] = updateParts
//
//        return true
//    }
//}
//
//extension PartsBoxBase: IteratorProtocol {
//    func next() -> Element? {
//        defer {
//            currentIndex += 1
//        }
//
//        if currentIndex >= count {
//           return nil
//        } else {
//            return parts[currentIndex]
//        }
//    }
//}
//
////extension PartsBoxBase: Collection, Sequence {
//extension PartsBoxBase: Collection {
//    func index(after i: Index) -> Index {
//        return i + 1
//    }
//
//    var startIndex: Index {
//        return 0
//    }
//
//    var endIndex: Index {
//        return parts.count
//    }
//
//    subscript(_ position: Index) -> Element {
//        return parts[position]
//    }
//}
