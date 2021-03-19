//
//  ValidationModel.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/03/19.
//

import Foundation
import RxSwift


enum ValidationError: Error {
    case invalidCodeFormat
    case invalidItemCountFormat
    case emptyCode
    case emptyItemCount
    case emptyCodeAndItemCount
}

class ValidationModel {
    /// 数字5桁に表示するテキスト
    var itemCodeTextObservable: Observable<String>
    
    /// 購入個数に表示するテキスト
    var itemNumberTextObservable: Observable<String>
        
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
    
    func validate(code: String) -> Observable<Void> {
        if code.allSatisfy({ $0.isNumber }) == false {
            return Observable.error(ValidationError.invalidCodeFormat)
        } else if code.count != 5 || code.allSatisfy({ $0.isNumber }) == false {
            return Observable.error(ValidationError.emptyCode)
        } else {
            return Observable.just(())
        }
    }

    // 購入数のバリデーション
    func validate2(count: String) -> Observable<Void> {
        if count.allSatisfy({ $0.isNumber }) == false {
            return Observable.error(ValidationError.invalidItemCountFormat)
        } else if count.count == 0 {
            return Observable.error(ValidationError.emptyItemCount)
        } else {
            return Observable.just(())
        }
    }

}
