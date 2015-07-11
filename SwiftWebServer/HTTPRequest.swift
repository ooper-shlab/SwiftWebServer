//
//  HTTPRequest.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/26.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension Array {
    func get(index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
    subscript(opt index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}

enum RequestValue {
    case Text(String)
    case Array([String])
}
extension RequestValue {
    func asArray() -> [String] {
        switch self {
        case Text(let value):
            return [value]
        case Array(let values):
            return values
        }
    }
    func asText() -> String {
        switch self {
        case Text(let value):
            return value
        case Array(let values):
            return values.first ?? ""
        }
    }
    func asInt() -> Int? {
        switch self {
        case Text(let value):
            return Int(value)
        case Array(let values):
            return values.first.flatMap{Int($0)}
        }
    }
}
class HTTPRequest {
    var headerData: NSData?
    var bodyData: NSData?
    var remoteAddress: SocketAddress
    var receiver: HTTPReceiver
    var method: String?
    var path: String?
    var httpVersion: String?
    var headers: HTTPValues = HTTPValues()
    private(set) lazy var scheme: String = self.receiver.secure ? "https" : "http"
    private(set) lazy var url: NSURL = NSURL(scheme: self.scheme, host: self.headers["host"], path: self.path!)!
    private(set) lazy var urlPath: String? = self.url.path
    private(set) lazy var urlQuery: String? = self.url.query
    
    init(receiver: HTTPReceiver, remoteAddress: SocketAddress) {
        self.remoteAddress = remoteAddress
        self.receiver = receiver
        self.headerData = receiver.receiveHeader()
        let requestHeader = NSString(data: headerData!, encoding: NSASCIIStringEncoding)! as String
        parseRequestHeader(requestHeader)
        print("headers:\r\n\(headers)")
        if let contentLength = headers["content-length"].flatMap({Int($0)}) {
            _ = receiver.receiveBody(contentLength)
        }
    }
    func parseRequestHeader(requestHeader: String) {
        var lineNumber = 0
        let spaces = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        requestHeader.enumerateLines {line, stop in
            if lineNumber == 0 {
                let methods = line.componentsSeparatedByCharactersInSet(spaces)
                self.method = methods[opt: 0]
                self.path = methods[opt: 1]
                self.httpVersion = methods[opt: 2]
                NSLog("methods=%@", methods)
            } else {
                if let index = line.rangeOfString(":") {
                    let name = line.substringToIndex(index.startIndex)
                    let value = line.substringFromIndex(index.endIndex).stringByTrimmingCharactersInSet(spaces)
                    self.headers.append(value, forName: name)
                }
            }
            ++lineNumber
        }
    }
}