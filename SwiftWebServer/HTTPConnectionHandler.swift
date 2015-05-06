//
//  HTTPConnectionHandler.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/13.
//  Copyright (c) 2014年 nagata_kobo. All rights reserved.
//

import Foundation

class HTTPConnectionHandler {
    static var handlerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    func handleConnection(clientSocket: Int32, sockAddr: SocketAddress) {
        let requestHandler = HTTPRequestHandler(socket: clientSocket, sockAddr: sockAddr,
            queue: HTTPConnectionHandler.handlerQueue)
        requestHandler.handleRequestEvent()
    }
}
