//
//  SwiftWebServerTest.swift
//  SwiftWebServerTest
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/6.
//  Copyright (c) 2015 nagata_kobo. All rights reserved.
//

import Cocoa
import XCTest

class SwiftWebServerTest: XCTestCase {

    var options = JSON.preprocessedOptions([:])
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
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse2() {
        let jsonString = "{ \"a\": 10.5 \"b\": [true false null] \"c\": \"\\r\\n\"}"
        var hasError = false
        let options = [
            "omittableComma": true
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse3() {
        let jsonString = "{ a: 10.5, b: [true, false, null], c: \"\\r\\n\"}"
        var hasError = false
        let options = [
            "unquotedKey": true
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse4() {
        let jsonString = "10.5"
        var hasError = false
        let json = JSON.parse(jsonString) {_ in hasError = true}
        XCTAssert(hasError && json == nil, "Pass")
    }
    
    func testJSONParse5() {
        let jsonString = "10.5"
        var hasError = false
        let options = [
            "acceptsScalar": true
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = 10.5
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse6() {
        let jsonString = "{ \"a\": 10.5, \"c\": \"\\r\\n\", \"b\": [true, false, null"
        var hasError = false
        let json = JSON.parse(jsonString) {_ in hasError = true}
        XCTAssert(hasError && json == nil, "Pass")
    }
    
    func testJSONParse7() {
        let jsonString = "{ \"a\": 10.5, \"c\": \"\\r\\n\", \"b\": [true, false, null"
        var hasError = false
        let options = [
            "eofTerminates": true
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse8() {
        let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null,], \"c\": \"\\r\\n\",}"
        var hasError = false
        let json = JSON.parse(jsonString) {_ in hasError = true}
        XCTAssert(hasError && json == nil, "Pass")
    }
    
    func testJSONParse9() {
        let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null,], \"c\": \"\\r\\n\",}"
        var hasError = false
        let options = [
            "trailingComma": true
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse10() {
        let jsonString = "{ \"a\": 10.5,//comment\n \"b\": [true, false, null],/* \"d\": 1,\r\n*/ \"c\": \"\\r\\n\"}"
        var hasError = false
        let json = JSON.parse(jsonString) {_ in hasError = true}
        XCTAssert(hasError && json == nil, "Pass")
    }
    
    func testJSONParse11() {
        let jsonString = "{ \"a\": 10.5,//comment\n \"b\": [true, false, null],/* \"d\": 1,\r\n*/ \"c\": \"\\r\\n\"}"
        var hasError = false
        let options = [
            "comments": true
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse12() {
        let settingsString = "a: 10.5 //comment\n"
        + "b: [true, false, null]\n"
        + "/* d: 1\n"
        + "*/ c: \"\\r\\n\""
        var hasError = false
        let json = JSON.parseSettings(settingsString) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 10.5, "c": "\r\n"]
        XCTAssert(!hasError && json! == expectedResult, "Pass")
    }
    
    func testJSONParse13() {
        let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null], \"c\": \"\\r\\n\", \"a\": 0}"
        var hasError = false
        let options = [
            "duplicateKey": false
        ]
        let json = JSON.parse(jsonString, options: options) {_ in hasError = true}
        XCTAssert(hasError && json == nil, "Pass")
    }
    
    func testJSONParse14() {
        let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null], \"c\": \"\\r\\n\", \"a\": 0}"
        var hasError = false
        let json = JSON.parse(jsonString) {_ in hasError = true}
        print(json!.debugDescription)
        let expectedResult: JSON = ["b": [true, false, nil], "a": 0, "c": "\r\n"]
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
    
    func testPerformance2() {
        // This is an example of a performance test case.
        self.measureBlock() {
            let jsonString = "{ \"a\": 10.5, \"b\": [true, false, null], \"c\": \"\\r\\n\"}"
            var hasError = false
            let json = JSON.parse(jsonString, options: self.options) {_ in hasError = true}
        }
    }
    
}
