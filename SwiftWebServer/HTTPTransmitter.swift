//
//  HTTPTransmitter.swift
//  SwiftWebServer
//
//  Created by 開発 on 2015/5/3.
//  Copyright (c) 2015 nagata_kobo. All rights reserved.
//

import Foundation

class HTTPTransmitter {
    var socket: Int32
    init(socket: Int32) {
        self.socket = socket
    }
    
    func send(message: String) {
        write(socket, message, count(message.utf8))
    }
    
    func send(data: NSData) {
        write(socket, data.bytes, data.length)
    }
    
    func close() {
        Darwin.close(socket)
    }
}