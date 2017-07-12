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
    
    func send(_ message: String) {
        write(socket, message, message.utf8.count)
    }
    
    func send(_ data: Data) {
        _ = data.withUnsafeBytes {bytes in
            write(socket, bytes, data.count)
        }
    }
    
    func close() {
        _ = Darwin.close(socket)
    }
}
