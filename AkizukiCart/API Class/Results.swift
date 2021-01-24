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
    
    // 購入予定数
    // 本来の JSON にはないので Optional で定義
    var buyCount: Int?
    var purchased: Bool?
    
    enum CodingKeys: String, CodingKey {
        case status
        case partNumber = "part_number"
        case stores
        case name
        case price
        case releaseDate = "release_date"
        case manufacturer, id
        case lastUpdate = "last_update"
        case buyCount
        case purchased
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
struct Store: Codable {
    let count: Int?
    let place, name: String
}

