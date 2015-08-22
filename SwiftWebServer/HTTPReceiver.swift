//
//  HTTPReceiver.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/4/26.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class HTTPReceiver {
    private(set) var secure: Bool = false
    
    let socket: Int32
    let headerData = NSMutableData(capacity: 1024)!
    var endOfHeader = -1
    let bodyData = NSMutableData()
    
    init(socket: Int32) {
        self.socket = socket
    }
    
    func receiveHeader() -> NSData {
        var buffer: [UInt8] = Array(count: 1024, repeatedValue: 0)
        headerData.length = 0
        endOfHeader = -1
        var currentHeaderBottom = 0
        repeat {
            let len = read(self.socket, &buffer, 1024)
            //TODO: error check, timeout check
            headerData.appendBytes(buffer, length: len)
            let emptyLine = headerData.rangeOfData(emptyLineData, options: [], range: NSRange(currentHeaderBottom..<headerData.length))
            if emptyLine.location == NSNotFound {
                if headerData.hasSuffix(CR, LF, CR) {
                    currentHeaderBottom = headerData.length - 3
                } else if headerData.hasSuffix(CR, LF) {
                    currentHeaderBottom = headerData.length - 2
                } else if headerData.hasSuffix(CR) {
                    currentHeaderBottom = headerData.length - 1
                } else {
                    currentHeaderBottom = headerData.length
                }
            } else {
                endOfHeader = emptyLine.location
            }
        } while endOfHeader == -1
        let startOfBody = NSRange(endOfHeader+4 ..< headerData.length)
        bodyData.appendData(headerData.subdataWithRange(startOfBody))
        headerData.length = endOfHeader+4
        return headerData
    }
    func receiveBody(length: Int) -> NSData {
        if bodyData.length > length {
            //TODO: error log
            return bodyData
        }
        var buffer: [UInt8] = Array(count: 1024, repeatedValue: 0)
        while bodyData.length < length {
            let lenRead = length - bodyData.length > 1024 ? 1024 : length - bodyData.length
            let len = read(self.socket, &buffer, lenRead)
            //TODO: error check, timeout check
            bodyData.appendBytes(buffer, length: len)
        }
        return bodyData
    }
}