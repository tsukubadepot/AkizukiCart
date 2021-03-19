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
    var itemCodeTextObservable: Observable<String>
        
    init(itemCode: Observable<String?>) {
        // 通販コードの数値は5桁で切り落とし
        itemCodeTextObservable = itemCode
                                    .compactMap { $0 }
                                    .skip(1)
                                    // これを入れると6桁目まで入力可能となる場合がある
                                    //.distinctUntilChanged()
                                    .map { $0.prefix(5).description }
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
}
