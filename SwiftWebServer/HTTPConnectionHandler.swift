//
//  HTTPConnectionHandler.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/10/13.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class HTTPConnectionHandler {
    static var handlerQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
    
    func handleConnection(_ clientSocket: Int32, sockAddr: SocketAddress) {
        autoreleasepool {
            let requestHandler = HTTPRequestHandler(socket: clientSocket, sockAddr: sockAddr,
                queue: HTTPConnectionHandler.handlerQueue)
            requestHandler.handleRequestEvent()
        }
    }
}
