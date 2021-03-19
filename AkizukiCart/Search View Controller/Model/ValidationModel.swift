//
//  ValidationModel.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/03/19.
//

import Foundation
import RxSwift

/// バリデーションの状態
enum ValidationError: Error {
    case invalidCodeFormat
    case invalidItemCountFormat
    case emptyCode
    case emptyItemCount
}

/// ValidationModel の Protocol
protocol ValidationModelProtocol {
    var itemCodeTextObservable: Observable<String> { get }
    var itemNumberTextObservable: Observable<String> { get }
    func validateItemCode(code: String) -> Observable<Void>
    func validateItemCount(count: String) -> Observable<Void>
}

class ValidationModel: ValidationModelProtocol {
    /// 数字5桁に表示するテキスト
    let itemCodeTextObservable: Observable<String>
    
    /// 購入個数に表示するテキスト
    let itemNumberTextObservable: Observable<String>
        
    init(itemCode: Observable<String?>, itemNumber: Observable<String?>) {
        // 通販コードの数値は5桁で切り落とし
        itemCodeTextObservable = itemCode
                                    .compactMap { $0 }
                                    .skip(1)
                                    // これを入れると6桁目まで入力可能となる場合がある
                                    //.distinctUntilChanged()
                                    .map { $0.prefix(5).description }
        
        //　通販コードの文字数は0文字より多く、また先頭がゼロではない
        itemNumberTextObservable = itemNumber
                                    .compactMap { $0 }
                                    .skip(1)
                                    .map { text in
                                        if text.count > 0 && text.first == "0" {
                                            return String(text.dropFirst())
                                        } else {
                                            return text
                                        }
                                    }
    }
    
    func validateItemCode(code: String) -> Observable<Void> {
        if code.allSatisfy({ $0.isNumber }) == false {
            return Observable.error(ValidationError.invalidCodeFormat)
        } else if code.count != 5 {
            return Observable.error(ValidationError.emptyCode)
        } else {
            return Observable.just(())
        }
    }

    // 購入数のバリデーション
    func validateItemCount(count: String) -> Observable<Void> {
        if count.allSatisfy({ $0.isNumber }) == false {
            return Observable.error(ValidationError.invalidItemCountFormat)
        } else if count.count == 0 {
            return Observable.error(ValidationError.emptyItemCount)
        } else {
            return Observable.just(())
        }
    }
}
