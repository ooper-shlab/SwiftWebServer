//
//  HTTPResponse.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/3.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class HTTPResponse {
    var transmitter: HTTPTransmitter
    
    var headers: HTTPValues = HTTPValues()
    
    var status: HTTPStatus = .ok
    var version: String = "HTTP/1.1"
    
    var contentType: String? {
        get {
            return headers["Content-Type"]
        }
        set {
            headers["Content-Type"] = newValue
        }
    }
    
    var contentLength: Int? {
        get {
            return headers["Content-Length"].flatMap{Int($0)}
        }
        set {
            if newValue == nil {
                headers.remove("Content-Length")
            } else {
                headers["Content-Length"] = String(newValue!)
            }
        }
    }
    
    private(set) var headerSent: Bool = false
    
    init(transmitter: HTTPTransmitter) {
        self.transmitter = transmitter
    }
    
    func sendHeaders() {
        if headerSent {
            fatalError("Header already sent")
        }
        print("\(version) \(status.fullDescription)\r\n")
        transmitter.send("\(version) \(status.fullDescription)\r\n")
        for (name, value) in headers {
            let header: String
            if value == nil {
                header = "\(name)\r\n"
            } else {
                header = "\(name): \(value!)\r\n"
            }
            transmitter.send(header)
            print(header)
        }
        transmitter.send("\r\n")
        headerSent = true
    }
}
