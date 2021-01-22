//
//  UserDefaultExtension.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/01/23.
//

import Foundation

//https://qiita.com/masakihori/items/7a0ed9d109800d714c0b
extension UserDefaults {
  func setEncoded<T: Encodable>(_ value: T, forKey key: String) {
    guard let data = try? JSONEncoder().encode(value) else {
       print("Can not Encode to JSON.")
       return
    }

    set(data, forKey: key)
  }

  func decodedObject<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
    guard let data = data(forKey: key) else {
      return nil
    }

    return try? JSONDecoder().decode(type, from: data)
  }
}
