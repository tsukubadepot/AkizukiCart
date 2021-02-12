//
//  Results.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import Foundation

// https://akizuki-api.appspot.com/

// MARK: - 成功時に得られる JSON に対応した Struct
struct PartsInfo: Codable {
    let status: Status
    // Part Number は　NULL の場合がある
    let partNumber: String?
    let stores: [Store]
    let name: String
    let price: Price
    let releaseDate: String
    let manufacturer: String?
    let id: String
    let lastUpdate: String

    // FIXME: Codable にすると全項目イニシャライザが作られない
    init(status: Status, partNumber: String?, stores: [Store], name: String, price: Price, releaseDate: String, manufacturer: String?, id: String, lastUpdate: String) {
        self.status = status
        self.partNumber = partNumber
        self.stores = stores
        self.name = name
        self.price = price
        self.releaseDate = releaseDate
        self.manufacturer = manufacturer
        self.id = id
        self.lastUpdate = lastUpdate
    }
    
    // 購入予定数
    // 本来の JSON にはないのでデフォルト値を入れておく
    // UserDefaults でシリアライズする時のために Computed Property にする
    var buyCount: Int  {
        get {
            return _buyCount ?? 1
        }
        set {
            _buyCount = newValue
        }
    }
    
    var purchased: Bool {
        get {
            return _purchased ?? false
        }
        
        set {
            _purchased = newValue
        }
    }
    
    private var _buyCount: Int?
    private var _purchased: Bool?
    
    enum CodingKeys: String, CodingKey {
        case status
        case partNumber = "part_number"
        case stores
        case name
        case price
        case releaseDate = "release_date"
        case manufacturer, id
        case lastUpdate = "last_update"
        case _buyCount = "buyCount"
        case _purchased = "purchased"
    }
}

// MARK: - 該当する商品がなかった場合の JSON
struct FailureResult: Codable {
    let status: Status
    let message, id: String
}

// MARK: Price
struct Price: Codable {
    let currency: String
    let value: Int
}

// MARK: Status
struct Status: Codable {
    let code: Int
    let statusDescription: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case statusDescription = "description"
    }
}

// MARK: Store
// 売り場情報が取れない場合の処理
struct Store: Codable {
    let count: Int?
    var place: String {
        if _place.isEmpty {
            return "売場：店員さんにお問い合わせください。"
        } else {
            return _place
        }
    }
    let name: String
    
    private let _place: String
    
    enum CodingKeys: String, CodingKey {
        case _place = "place"
        case count
        case name
    }
}

// MARK: Componets
// 複数 ID を取得する場合
struct Components: Codable {
    var components: [ComponentsPartsInfo]
}

// MARK: ComponentsPartsInfo
// TODO: より効率的な処理を考える必要がある。
// 今回は、components に PartsInfo と FailureResult の両方が混在し、それをうまく decode で切り分けらないため混在させたが、
// 何らかの方法で切り分け可能にすべき
struct ComponentsPartsInfo: Codable {
    // 両者共通
    let status: Status
    
    // 該当した場合に得られる
    let partNumber: String?
    let manufacturer: String?
    let id: String
    
    // 両者共通仕様に対応するため、やむなく Optional にした内部値の処理
    private var _stores: [Store]?
    var stores: [Store] {
        get {
            return _stores ?? []
        }
        set {
            _stores = newValue
        }
    }
    
    private var _name: String?
    var name: String {
        get {
            return _name ?? ""
        }
        set {
            _name = newValue
        }
    }
    private var _price: Price?
    var price: Price {
        get {
            return _price ?? Price(currency: "", value: 0)
        }
        set {
            _price = newValue
        }
    }
    
    private var _releaseDate: String?
    var releaseDate: String {
        get {
            return _releaseDate ?? ""
        }
        set {
            _releaseDate = newValue
        }
    }
    
    private var _lastUpdate: String?
    var lastUpdate: String {
        get {
            return _lastUpdate ?? ""
        }
        set {
            _lastUpdate = newValue
        }
    }
    
    // FIXME: この構造体を直接保存することはないので、以下の行は不要かもしれない
    // 購入予定数
    // 本来の JSON にはないのでデフォルト値を入れておく
    // UserDefaults でシリアライズする時のために Computed Property にする
    var buyCount: Int {
        get {
            return _buyCount ?? 1
        }
        set {
            _buyCount = newValue
        }
    }
    
    var purchased: Bool {
        get {
            return _purchased ?? false
        }
        
        set {
            _purchased = newValue
        }
    }
    
    private var _buyCount: Int?
    private var _purchased: Bool?
    
    // 失敗した場合
    let message: String?

    enum CodingKeys: String, CodingKey {
        case status
        case partNumber = "part_number"
        case _stores = "stores"
        case _name = "name"
        case _price = "price"
        case _releaseDate = "release_date"
        case manufacturer, id
        case _lastUpdate = "last_update"
        case _buyCount = "buyCount"
        case _purchased = "purchased"
        case message
    }
}
