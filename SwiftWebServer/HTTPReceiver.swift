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
    var headerData = Data(capacity: 1024)
    var endOfHeader = -1
    var bodyData = Data()
    
    init(socket: Int32) {
        self.socket = socket
    }
    
    func receiveHeader() -> Data {
        var buffer: [UInt8] = Array(repeating: 0, count: 1024)
        headerData.count = 0
        endOfHeader = -1
        var currentHeaderBottom = 0
        repeat {
            let len = read(self.socket, &buffer, 1024)
            //TODO: error check, timeout check
            headerData.append(buffer, count: len)
            if let emptyLine = headerData.range(of: emptyLineData, options: [], in: currentHeaderBottom..<headerData.count) {
                endOfHeader = emptyLine.lowerBound
            } else {
                if headerData.hasSuffix(CR, LF, CR) {
                    currentHeaderBottom = headerData.count - 3
                } else if headerData.hasSuffix(CR, LF) {
                    currentHeaderBottom = headerData.count - 2
                } else if headerData.hasSuffix(CR) {
                    currentHeaderBottom = headerData.count - 1
                } else {
                    currentHeaderBottom = headerData.count
                }
            }
        } while endOfHeader == -1
        bodyData.append(headerData[endOfHeader+4 ..< headerData.count])
        headerData.count = endOfHeader+4
        return headerData
    }
    func receiveBody(_ length: Int) -> Data {
        if bodyData.count > length {
            //TODO: error log
            return bodyData
        }
        var buffer: [UInt8] = Array(repeating: 0, count: 1024)
        while bodyData.count < length {
            let lenRead = length - bodyData.count > 1024 ? 1024 : length - bodyData.count
            let len = read(self.socket, &buffer, lenRead)
            //TODO: error check, timeout check
            bodyData.append(buffer, count: len)
        }
        return bodyData
    }
}
