//
//  AkizukiCartTests.swift
//  AkizukiCartTests
//
//  Created by Jun Yamashita on 2021/02/10.
//

import XCTest
@testable import AkizukiCart

class SearchItemModelTests: XCTestCase {
    /// 複数アイテムのサーチに関するテスト
    func testSearchItems() {
        // 待機用の XCTestException を生成する
        let expForError = expectation(description: "Server did not respond in 10 seconds.")

        APIHandler.searchItems(["", "M-13289", "XXXXXX"]) { comp in
            print(comp)
            // TODO: エラーコードに注意
            // 現時点の仕様では、複数のIDを取得しようとした場合、その中にIDとして条件が満たされない物が含まれていても、
            // サーバとしての Status Code は 200 になる。
            // したがって、クロージャに渡された個別のステータスコードを見た上で、ID が存在するか否かを判断する必要がある。
            expForError.fulfill()
        } notfoundHandler: { fail in
            // 400番台が出る具体的な事例は現時点では不明（サーバの仕様で400番台は返さない可能性がある）
            XCTFail(fail.message)
        } errorHadler: { error in
            // ここに到達した場合は URL の不正やネットワーク不達など。
            XCTFail(error.localizedDescription)
        }
    
        wait(for: [expForError], timeout: 10)
    }
    
    /// 複数アイテムを10個程度に分割し、再帰的にサーチさせるテスト
    func testSearchAllItems() {
        let item = ["M-07385", "M-09607", "K-08217", "M-11647", "K-06503", "K-07378", "M-09059", "M-14848", "K-09035", "K-06894",
                    "M-07381", "K-15200", "M-07612", "K-07234", "K-07243", "M-06324", "K-13646", "K-08780", "K-06791", "M-06897",
                    "M-06560", "K-11755", "M-10066", "M-13031", "M-13688", "K-12144", "M-08942", "M-07384", "M-08286", "M-07383",
                    "K-07095", "K-01271", "M-13689", "M-07386", "K-06720", "M-13687", "M-13289", "K-02018", "M-06680", "M-09687",
                    "M-14448", "M-10133", "M-06931", "M-10096", "M-06926", "M-10094", "M-07735", "M-11108", "K-07231", "M-11109",
                    "K-10657", "M-06927", "M-06706", "M-06684", "K-06854", "M-06455", "K-06486", "M-12172", "M-10095", "M-07711",
                    "K-01671", "M-09520", "K-07256", "M-07183", "M-06453", "M-10045", "M-06836", "M-06832", "K-02272", "M-10885",
                    "K-09796", "M-08773", "M-06948", "M-06930", "M-06588", "M-06545", "M-06458", "M-06323", "M-06263", "K-02327",
                    "M-11110", "M-09913", "M-09912", "M-09446", "M-09393", "M-09076", "M-08060", "M-08059", "M-07182", "M-06928"]

        
        let searchItemModel = SearchItemModel(items: item)
        
        // 進捗表示
        searchItemModel.delegate = self
        
        // 待機用の XCTestException を生成する
        let timeout = 120.0
        let expForError = expectation(description: "Server did not respond in \(timeout) seconds.")

        searchItemModel.search {
            XCTAssertEqual(searchItemModel.components.count, item.count, "渡した要素数と応答数が同じ")
            expForError.fulfill()
        } errorHandler: { error in
            print(error.localizedDescription)
        }

        wait(for: [expForError], timeout: timeout)
    }
    
    /// 複数アイテムを検索した上、検索に成功した商品だけ抜き出す
    func testSearchAllItemsAndGetValidItems() {
        let item = ["M-07385", "M-09607", "K-08217", "M-11647", "K-06503", "K-07378", "M-09059", "M-14848", "K-09035", "K-06894",
                    "M-07381", "K-15200", "M-07612", "K-07234", "K-07243", "M-06324", "K-13646", "K-08780", "K-06791", "M-06897",
                    "M-06560", "K-11755", "M-10066", "M-13031", "M-13688", "K-12144", "M-08942", "M-07384", "M-08286", "M-07383",
                    "K-07095", "K-01271", "M-13689", "M-07386", "K-06720", "M-13687", "M-13289", "K-02018", "M-06680", "M-09687",
                    "M-14448", "M-10133", "M-06931", "M-10096", "M-06926", "M-10094", "M-07735", "M-11108", "K-07231", "M-11109",
                    "K-10657", "M-06927", "M-06706", "M-06684", "K-06854", "M-06455", "K-06486", "M-12172", "M-10095", "M-07711",
                    "K-01671", "M-09520", "K-07256", "M-07183", "M-06453", "M-10045", "M-06836", "M-06832", "K-02272", "M-10885",
                    "K-09796", "M-08773", "M-06948", "M-06930", "M-06588", "M-06545", "M-06458", "M-06323", "M-06263", "K-02327",
                    "M-11110", "M-09913", "M-09912", "M-09446", "M-09393", "M-09076", "M-08060", "M-08059", "M-07182", "M-06928"]

        
        let searchItemModel = SearchItemModel(items: item)
        
        // 進捗表示
        searchItemModel.delegate = self
        
        // 待機用の XCTestException を生成する
        let timeout = 120.0
        let expForError = expectation(description: "Server did not respond in \(timeout) seconds.")

        searchItemModel.search {
            XCTAssertEqual(searchItemModel.components.count, item.count, "渡した要素数と応答数が同じ")
            dump(searchItemModel.getItemsFromSearchResult().count)
            expForError.fulfill()
        } errorHandler: { error in
            print(error.localizedDescription)
        }

        wait(for: [expForError], timeout: timeout)
    }
    
    /// 空配列を渡した時のテスト
    func testSearchEmptyItems() {
        let item: [String] = []

        let searchItemModel = SearchItemModel(items: item)
        
        // 進捗表示
        searchItemModel.delegate = self
        
        // 待機用の XCTestException を生成する
        let timeout = 120.0
        let expForError = expectation(description: "Server did not respond in \(timeout) seconds.")

        searchItemModel.search {
            // ここには到達しないはず
            XCTFail("空配列の場合いはここには到達しない。")
        } errorHandler: { error in
            if let error = error as? SearchItemError {
                print(error.localizedDescription)
            } else {
                XCTFail("fail")
                print(error.localizedDescription)
            }
            expForError.fulfill()
        }

        wait(for: [expForError], timeout: timeout)
    }

}

extension SearchItemModelTests: SearchItemModelDelegate {
    // 進捗率の表示
    func searchItemModel(_ searchItemModel: SearchItemModel, progress: Double) {
        let text = String(format: "%.2f", progress * 100)
        print("progress: \(text) %%")
    }
}
