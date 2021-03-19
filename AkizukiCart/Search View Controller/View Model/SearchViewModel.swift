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

protocol SearchViewModelProtocol {
    var itemCodeTextObservable: Observable<String> { get }
    var showErrorHUDObservable: Observable<String> { get }
    var itemCodeTextIsOkObservable: Observable<Bool> { get }
    var itemNumberTextObservable: Observable<String> { get }
    var itemNumberTextIsOkObservable: Observable<Bool> { get }
}

class SearchViewModel: SearchViewModelProtocol {
    /// 数字5桁に表示するテキスト
    let itemCodeTextObservable: Observable<String>
    ///　HUDに表示する文字列
    let showErrorHUDObservable: Observable<String>
    /// 数字5桁が要件を満たしているか
    let itemCodeTextIsOkObservable: Observable<Bool>
    /// 購入個数に表示するテキスト
    let itemNumberTextObservable: Observable<String>
    /// 購入個数が要件を満たしているか
    let itemNumberTextIsOkObservable: Observable<Bool>
    
    private var disposeBag = DisposeBag()
    
    init(itemCode: Observable<String?>, itemCount: Observable<String?>) {
        let model = ValidationModel(itemCode: itemCode, itemNumber: itemCount)
        
        // 通販コードに表示する文字列
        itemCodeTextObservable = model.itemCodeTextObservable
        
        // 購入個数に表示する文字列
        itemNumberTextObservable = model.itemNumberTextObservable
        
        // バリデーション
        // 通販コード
        let itemCodeValidation = itemCodeTextObservable
            .flatMap { code -> Observable<Event<Void>> in
                return model.validateItemCode(code: code).materialize()
            }
            .share()
        
        // 購入数
        let itemCountValidation = itemNumberTextObservable
            .flatMap { count -> Observable<Event<Void>> in
                return model.validateItemCount(count: count).materialize()
            }
            .share()
        
        // 通販コード、購入数のいずれかに不正な値が入ったときの処理
        self.showErrorHUDObservable = Observable
            // Observable<> を 2 つまとめる
            .of(itemCodeValidation, itemCountValidation)
            // うち最新の 1 つだけを取得する
            .merge()
            .flatMap { event -> Observable<String> in
                switch event {
                case .error(let error as ValidationError):
                    switch error {
                    case .invalidCodeFormat, .invalidItemCountFormat:
                        return .just("数値を入力してください")
                    default:
                        return .empty()
                    }
                    
                default:
                    return .empty()
                }
            }
        
        // バリデーションに通過したかチェックし、対応す状態を送る
        self.itemCodeTextIsOkObservable = itemCodeValidation
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
            .startWith(false)
        
        self.itemNumberTextIsOkObservable = itemCountValidation
            .flatMap { event -> Observable<Bool> in
                switch event {
                case .error(let error as ValidationError):
                    switch error {
                    case .emptyItemCount, .invalidItemCountFormat:
                        return .just(false)
                        
                    default:
                        return .just(true)
                    }
                    
                default:
                    return .just(true)
                }
            }
            .startWith(false)
    }
}

