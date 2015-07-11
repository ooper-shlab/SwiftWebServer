//
//  HTTPTransmitter.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/3.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class HTTPTransmitter {
    var socket: Int32
    init(socket: Int32) {
        self.socket = socket
    }
    
    func send(message: String) {
        write(socket, message, message.utf8.count)
    }
    
    func send(data: NSData) {
        write(socket, data.bytes, data.length)
    }
    
    func close() {
        Darwin.close(socket)
    }
}