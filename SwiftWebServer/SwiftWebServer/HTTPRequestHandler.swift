//
//  HTTPRequestHandler.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/13.
//  Copyright (c) 2014 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class HTTPRequestHandler {
    let requestSocket: Int32
    let requestAddress: SocketAddress
    let localAddress: SocketAddress
    init(socket: Int32, sockAddr: SocketAddress, queue: dispatch_queue_t) {
        self.requestSocket = socket
        self.requestAddress = sockAddr
        var localSockAddr: sockaddr = sockaddr()
        var localSockAddrLen: socklen_t = socklen_t(sizeof(sockaddr))
        if getsockname(socket, &localSockAddr, &localSockAddrLen) == 0 {
            localAddress = SocketAddress(sockaddrPtr: &localSockAddr)
        } else {
            //TODO: Handle the error.
            localAddress = SocketAddress.SysError(errno: errno)
        }
        //
        var nosigpipe: Int32 = 1
        if setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, socklen_t(sizeof(Int32))) != 0 {
            //TODO: Handle the error.
            SysErrorLog(errno)
        }
    }
    func handleRequestEvent() -> Void {
        NSLog("recieving request")
        let receiver = HTTPReceiver(socket: self.requestSocket)
        let request = HTTPRequest(receiver: receiver, remoteAddress: self.requestAddress)
        let transmitter = HTTPTransmitter(socket: requestSocket)
        let response = HTTPResponse(transmitter: transmitter)
        NSLog("%@ %@ %@", request.method!, request.path!, request.httpVersion!)
        let director = ChiefDirector.findDirector(request, response)
        director.direct()
    }
}