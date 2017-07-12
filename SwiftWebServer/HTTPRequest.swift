//
//  HTTPRequest.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/26.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

//enum RequestValue {
//    case Text(String)
//    case Array([String])
//}
//extension RequestValue {
//    func asArray() -> [String] {
//        switch self {
//        case Text(let value):
//            return [value]
//        case Array(let values):
//            return values
//        }
//    }
//    func asText() -> String {
//        switch self {
//        case Text(let value):
//            return value
//        case Array(let values):
//            return values.first ?? ""
//        }
//    }
//    func asInt() -> Int? {
//        switch self {
//        case Text(let value):
//            return Int(value)
//        case Array(let values):
//            return values.first.flatMap{Int($0)}
//        }
//    }
//}
class HTTPRequest {
    var headerData: Data?
    var bodyData: Data?
    var remoteAddress: SocketAddress
    var receiver: HTTPReceiver
    var method: String?
    var path: String?
    var httpVersion: String?
    var headers: HTTPValues = HTTPValues(caseInsensitive: true)
    private(set) lazy var scheme: String = self.receiver.secure ? "https" : "http"
    private(set) lazy var url: URL = {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.headers["host"]
        urlComponents.path = self.path!
        return urlComponents.url!
    }()
    private(set) lazy var urlPath: String? = self.url.path
    private(set) lazy var urlQuery: String? = self.url.query
    
    init(receiver: HTTPReceiver, remoteAddress: SocketAddress) {
        self.remoteAddress = remoteAddress
        self.receiver = receiver
        self.headerData = receiver.receiveHeader()
        let requestHeader = String(data: headerData!, encoding: .ascii)!
        parseRequestHeader(requestHeader)
        print("headers:\r\n\(headers)")
        if let contentLength = headers["content-length"].flatMap({Int($0)}) {
            _ = receiver.receiveBody(contentLength)
        }
    }
    func parseRequestHeader(_ requestHeader: String) {
        var lineNumber = 0
        let spaces = CharacterSet.whitespacesAndNewlines
        requestHeader.enumerateLines {line, stop in
            if lineNumber == 0 {
                let methods = line.components(separatedBy: spaces)
                self.method = methods[opt: 0]
                self.path = methods[opt: 1]
                self.httpVersion = methods[opt: 2]
                NSLog("methods=%@", methods)
            } else {
                if let index = line.range(of: ":") {
                    let name = line.substring(to: index.lowerBound)
                    let value = line.substring(from: index.upperBound).trimmingCharacters(in: spaces)
                    self.headers.append(value, for: name)
                }
            }
            lineNumber += 1
        }
    }
}
