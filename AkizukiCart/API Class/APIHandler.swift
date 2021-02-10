//
//  APIHandler.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2020/12/11.
//

import Foundation
import Alamofire

class APIHandler {
    /// 指定されたアイテム番号で商品を検索する
    /// - Parameters:
    ///   - item: ^[MKPBRSICT]-[0-9]{5}$.json 形式のアイテム番号
    ///   - successHandler: 検索成功時の処理ハンドラ
    ///   - notfoundHandler: 該当商品が見つからない場合の処理ハンドラ
    ///   - errorHadler: 例外処理（ネットワークエラーなど）の処理ハンドラ
    static func searchItem(_ item: String, successHandler: @escaping (PartsInfo) -> Void, notfoundHandler: @escaping (FailureResult) -> Void, errorHadler: @escaping (Error) -> Void) {
        let searchURL = URL(string: "https://akizuki-api.appspot.com/component")!.appendingPathComponent(item)
        
        AF.request(searchURL).responseJSON { result in
            if let error = result.error {
                DispatchQueue.main.async {
                    errorHadler(error)
                    
                    return
                }
            }
            
            switch result.result {
            case .failure(let error):
                // タイムアウトなど
                DispatchQueue.main.async {
                    errorHadler(error)
                    return
                }
                
            case .success:
                switch result.response!.statusCode {
                case 200...299:
                    do {
                        var parts = try JSONDecoder().decode(PartsInfo.self, from: result.data!)
                        
                        // 初期設定
                        parts.buyCount = 0
                        parts.purchased = false
                        
                        DispatchQueue.main.async {
                            successHandler(parts)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            errorHadler(error)
                        }
                    }
                    
                case 400...499:
                    do {
                        let fail = try JSONDecoder().decode(FailureResult.self, from: result.data!)
                        
                        DispatchQueue.main.async {
                            notfoundHandler(fail)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            errorHadler(error)
                        }
                    }
                    
                default:
                    fatalError()
                }
            }
        }
    }
}
