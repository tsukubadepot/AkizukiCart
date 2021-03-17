//
//  PartsBoxModelTest.swift
//  AkizukiCartTests
//
//  Created by Jun Yamashita on 2021/02/15.
//

import XCTest
@testable import AkizukiCart

// テストケース用のシングルトン
final class TestPartsBox: TestPartsBoxBase {
    static let shared = TestPartsBox()
    
    private init() {
        super.init(key: "test")
    }
}

class PartsBoxModelTest: XCTestCase {
    func testMakeSinglton() {
        let testBox = TestPartsBox.shared
        
        XCTAssertTrue(testBox.isEmpty, "要素は空")
        XCTAssertEqual(testBox.count, 0)
        
    }
    
    func testAppendSingleParts() {
        let item = PartsInfo(status: Status(code: 0, statusDescription: "test"),
                             partNumber: "11111",
                             stores: [],
                             name: "aaaa",
                             price: Price(currency: "JPY", value: 100),
                             releaseDate: "20210210",
                             manufacturer: "test",
                             id: "11111",
                             lastUpdate: "AAAAA")
    
    }
}
