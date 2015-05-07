//
//  HTTPConnectionHandler.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/13.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class HTTPConnectionHandler {
    static var handlerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    func handleConnection(clientSocket: Int32, sockAddr: SocketAddress) {
        autoreleasepool {
            let requestHandler = HTTPRequestHandler(socket: clientSocket, sockAddr: sockAddr,
                queue: HTTPConnectionHandler.handlerQueue)
            requestHandler.handleRequestEvent()
        }
    }
}
