//
//  SwiftWebServerTest.swift
//  SwiftWebServerTest
//
//  Created by 開発 on 2015/5/6.
//  Copyright (c) 2015年 nagata_kobo. All rights reserved.
//

import Cocoa
import XCTest

class SwiftWebServerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSONParse() {
        let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null], \"c\": \"\\r\\n\"}"
        var hasError = false
        let json = JSON.parse(jsonString) {_ in hasError = true}
        println(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null], \"c\": \"\\r\\n\"}"
            var hasError = false
            let json = JSON.parse(jsonString) {_ in hasError = true}
        }
    }
    
}
