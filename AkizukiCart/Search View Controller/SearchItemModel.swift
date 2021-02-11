//
//  SearchItemModel.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/02/11.
//

import Foundation

protocol SearchItemModelDelegate: AnyObject {
    /// 進捗率を伝える delegate
    /// - Parameters:
    ///   - searchItemModel: モデル自身のインスタンス
    ///   - progress: 検索進捗率
    func searchItemModel(_ searchItemModel: SearchItemModel, progress: Double)
}

// 検索実行時のエラーに関する定義
enum SearchItemError: Error, CustomDebugStringConvertible, LocalizedError {
    case searchItemIsEmpty(String)
    
    var localizedDescription: String {
        debugDescription
    }
    
    var debugDescription: String {
        switch self {
        case let .searchItemIsEmpty(message):
            return message
        }
    }
}

class SearchItemModel {
    /// 検索する商品の通販番号
    private(set) var items: [String]
    
    /// 検索結果の生データ
    private(set) var components: [ComponentsPartsInfo] = []

    weak var delegate: SearchItemModelDelegate?
    
    init(items: [String]) {
        self.items = items
    }
    
    /// 検索する商品のセット
    /// - Parameter items: 検索したい商品の通販番号
    func setItems(items: [String]) {
        self.items = items
    }
    
    /// 検索実行
    /// - Parameters:
    ///   - completion: 検索成功時のハンドラ
    ///   - errorHandler: 検索失敗時のハンドラ
    func search(completion: @escaping () -> Void, errorHandler: @escaping (Error) -> Void) {
        // 検索対象商品がない場合
        if items.isEmpty {
            let error: SearchItemError  = .searchItemIsEmpty("List of search items is empty.")
            errorHandler(error)
            return
        }
        
        // サーバの負荷を避けるため、検索対象商品を10個単位で区切る
        let searchItems = items.chunked(by: 10)
        let count = searchItems.count
        
        components.removeAll()
        
        searchAllItems(searchItems: searchItems, index: count - 1, completion: completion, errorHandler: errorHandler)
    }
    
    /// 検索結果の生データから有効なパーツリストを生成する
    /// - Returns: パーツリスト
    func getItemsFromSearchResult() -> [PartsInfo] {
        return components.reduce(into: []) { (result, component) in
            if component.status.code == 200 {
                let parts = PartsInfo(status: component.status,
                                      partNumber: component.partNumber,
                                      stores: component.stores,
                                      name: component.name,
                                      price: component.price,
                                      releaseDate: component.releaseDate,
                                      manufacturer: component.manufacturer,
                                      id: component.id,
                                      lastUpdate: component.lastUpdate)
                result.append(parts)
            }
        }
    }
    
    
    /// 検索の実行処理。再帰的に処理するので、初期呼び出し時 index は配列要素数の最大値（count - 1）を与える
    /// - Parameters:
    ///   - searchItems: 検索させたい商品番号の配列
    ///   - index: 検索させる配列の要素番号
    ///   - completion: 検索成功時のハンドラ
    ///   - errorHandler: 検索失敗時のハンドラ
    private func searchAllItems(searchItems: [[String]], index: Int, completion: @escaping () -> Void, errorHandler: @escaping (Error) -> Void) {
        // 進捗率の提供
        delegate?.searchItemModel(self, progress: Double(components.count) / Double(items.count))
        
        // 複数のアイテムを再帰的に検索する
        APIHandler.searchItems(searchItems[index]) { parts in
            // 検索結果の追加
            self.components.append(contentsOf: parts.components)
            
            if index > 0 {
                // 検索する商品が残っている場合には、再帰的に検索
                self.searchAllItems(searchItems: searchItems, index: index - 1, completion: completion, errorHandler: errorHandler)
            } else {
                // 検索する商品が残っていない場合には検索終了
                self.delegate?.searchItemModel(self, progress: Double(self.components.count) / Double(self.items.count))
                
                completion()
            }
        } notfoundHandler: { failure in
            // FIXME: 現時点ではここに到達する要因はない。
            completion()
        } errorHadler: { error in
            errorHandler(error)
        }
    }
}
