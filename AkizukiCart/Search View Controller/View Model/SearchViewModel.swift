//
//  SearchViewModel.swift
//  AkizukiCart
//
//  Created by Jun Yamashita on 2021/03/19.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchViewModelInput {
}

class SearchViewModel {
    // 数字5桁に表示するテキスト
    var itemCodeTextObservable: Observable<String>
    //　HUDに表示する文字列
    var showErrorHUDObservable: Observable<String>
    // 数字5桁が要件を満たしているか
    var itemCodeTextIsOkObservable: Observable<Bool>
    
    private var disposeBag = DisposeBag()
    
    init(itemCode: Observable<String?>) {
        let model = ValidationModel(itemCode: itemCode)
        
        // 通販コードに表示する文字列
        itemCodeTextObservable = model.itemCodeTextObservable
        
        // バリデーション
        let event = itemCodeTextObservable
            .flatMap { code -> Observable<Event<Void>> in
                return model.validate(code: code).materialize()
            }
            .share()
        
        self.showErrorHUDObservable = event
            .flatMap { event -> Observable<String> in
                switch event {
                case .error(let error as ValidationError):
                    switch error {
                    case .invalidCodeFormat:
                        return .just("数値を入力してください")
                    case .invalidItemCountFormat:
                        return .just("数値を入力してください")
                    default:
                        return .empty()
                    }
                    
                default:
                    return .empty()
                }
            }
        
        self.itemCodeTextIsOkObservable = event
            .flatMap { event -> Observable<Bool> in
                switch event {
                
                case .error(let error as ValidationError):
                    switch error {
                    case .emptyCode, .invalidCodeFormat:
                        return .just(false)
                        
                    default:
                        return .just(true)
                    }
                    
                default:
                    return .just(true)
                }
            }
    }
}

