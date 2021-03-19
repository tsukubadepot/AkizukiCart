//
//  APIHandlerTests.swift
//  AkizukiCartTests
//
//  Created by Jun Yamashita on 2021/03/19.
//

import XCTest
import RxSwift
@testable import AkizukiCart

class APIHandlerTests: XCTestCase {
    /// 存在するパーツを一つだけダウンロードするテストケース
    func testBasicDownloadTest() {
        // 待機用の XCTestException を生成する
        let expForError = expectation(description: "Server did not respond in 10 seconds.")
        
        let itemNumber = "P-16143"
        
        let model = APIHandler()
        let disposeBag = DisposeBag()
        
        model.downloadStateObservable
            .subscribe { state in
                switch state {
                case .loading:
                    print("start downloading")
                    
                case .finish(let partsInfo):
                    print(partsInfo)
                    XCTAssertEqual(partsInfo.id, itemNumber, "要求したパーツIDと取得したパーツIDが同じ")
                    expForError.fulfill()
                    
                case .failure(let failureInfo):
                    //　サーバ側のエラー
                    XCTFail(failureInfo.message)
                }
            } onError: { error in
                // なんらかのエラー
                XCTFail(error.localizedDescription)
            } onCompleted: {
                print("download finished")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)

        // ダウンロード開始
        model.fetchItem(itemNumber + ".json")
        
        wait(for: [expForError], timeout: 10)
    }
   
    /// 存在しないパーツ名でダウンロードするテストケース
    func testIncollectFormatTest() {
        // 待機用の XCTestException を生成する
        let expForError = expectation(description: "Server did not respond in 10 seconds.")
        
        let itemNumber = "XXXXX"
        
        let model = APIHandler()
        let disposeBag = DisposeBag()
        
        model.downloadStateObservable
            .subscribe { state in
                switch state {
                case .loading:
                    print("start downloading")
                    
                case .finish(let partsInfo):
                    dump(partsInfo)
                    XCTFail("常に失敗するのでここには到達しない")
                    
                case .failure(let failureInfo):
                    XCTAssertFalse(failureInfo.message.isEmpty, "エラーメッセージは空ではない")
                    expForError.fulfill()
                }
            } onError: { error in
                // なんらかのエラー
                XCTFail(error.localizedDescription)
            } onCompleted: {
                print("download finished")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)

        // ダウンロード開始
        model.fetchItem(itemNumber + ".json")
        
        wait(for: [expForError], timeout: 10)
    }

}
