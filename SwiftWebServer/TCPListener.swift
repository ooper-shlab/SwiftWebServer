//
//  TCPListener.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/10/13.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

enum SocketAddress {
    case IPv4(sockaddr_in)
    case IPv6(sockaddr_in6)
    case SysError(errno: Int32)
    case Error(NSError)
}

extension SocketAddress {
    init(sockaddrPtr: UnsafePointer<sockaddr>) {
        switch sockaddrPtr.memory.sa_family {
        case sa_family_t(AF_INET):
            let sockaddr4Ptr = UnsafePointer<sockaddr_in>(sockaddrPtr)
            self = IPv4(sockaddr4Ptr.memory)
        case sa_family_t(AF_INET6):
            let sockaddr6Ptr = UnsafePointer<sockaddr_in6>(sockaddrPtr)
            self = IPv6(sockaddr6Ptr.memory)
        default:
            self = SysError(errno: -1)
        }
    }
}

class TCPListener {
    private var listener_socket: Int32 = -1
    private var dispatch_source: dispatch_source_t?
    
    var connectionHandler: ((Int32, SocketAddress)->Void)?
    
    static var queue: dispatch_queue_t = dispatch_get_main_queue()
    init?() {
        
        if self.createSocket() < 0 {
            return nil
        }
        
        if self.setSocketOption() < 0 {
            return nil
        }
        
        if self.bind() < 0 {
            return nil
        }
        
        if self.listen() < 0 {
            return nil
        }
        
        if self.createSource() < 0 {
            return nil
        }
        
        self.setHandler()
        self.resume()
    }
    
    deinit {
        if dispatch_source != nil {
            dispatch_source_cancel(dispatch_source!)
        }
        if listener_socket >= 0 {
            close(listener_socket)
        }
    }
    
    func createSocket() -> Int32 {
        return -1
    }

    func setSocketOption() -> Int32 {
        var reuse: Int32 = 1
        if setsockopt(listener_socket, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(sizeof(Int32))) != 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return 0
    }
    
    func bind() -> Int32 {
        return -1
    }
    
    func listen() -> Int32 {
        let backlogs = Options.instance.backlogs
        
        if Foundation.listen(listener_socket, backlogs) < 0 {
            //error
            SysErrorLog(errno)
            return -1
        }
        
        return 0
    }
    
    func createSource() -> Int32 {
        
        let listen_queue = TCPListener.queue
        
        dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(listener_socket), 0, listen_queue)
        if dispatch_source == nil {
            //error
            NSLog("error in %@:%d", __FILE__, __LINE__)
            return -1
        }
        return 0
    }
    
    func setHandler() {
    }
    
    func resume() {
        dispatch_resume(dispatch_source!)
    }
}

class TCPListenerIPv4: TCPListener {
    override func createSocket() -> Int32 {
        listener_socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
        if listener_socket < 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return listener_socket
    }
    
    override func bind() -> Int32 {
        
        let port = Options.instance.port
        
        var sin: sockaddr_in = sockaddr_in()
        sin.sin_len = UInt8(sizeof(sockaddr_in))
        sin.sin_family = sa_family_t(AF_INET)
        sin.sin_port = htons(port)
        sin.sin_addr.s_addr = htonl(INADDR_ANY)
        //
        if withUnsafePointer(&sin, {sinPtr in
        Foundation.bind(listener_socket, UnsafePointer<sockaddr>(sinPtr), socklen_t(sizeof(sockaddr_in)))
        }) < 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return 0
    }
    
    override func setHandler() {
        dispatch_source_set_event_handler(dispatch_source!) {
            var sin: sockaddr_in = sockaddr_in()
            var len: socklen_t = socklen_t(sizeof(sockaddr_in))
            let client_sock = withUnsafeMutablePointer(&sin) {sinPtr in
                return accept(self.listener_socket, UnsafeMutablePointer<sockaddr>(sinPtr), &len)
            }
            
            let ip_addr = ntohl(sin.sin_addr.s_addr)
            NSLog("got request: ip=%08x", ip_addr)
            
            self.connectionHandler?(client_sock, SocketAddress.IPv4(sin))
        }
    }
}

class TCPListenerIPv6: TCPListener {
    override func createSocket() -> Int32 {
        listener_socket = socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP)
        if listener_socket < 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return listener_socket
    }
    
    override func bind() -> Int32 {
        
        let port = Options.instance.port
        
        var sin6: sockaddr_in6 = sockaddr_in6()
        sin6.sin6_len = UInt8(sizeof(sockaddr_in6))
        sin6.sin6_family = sa_family_t(AF_INET6)
        sin6.sin6_port = htons(port)
        sin6.sin6_addr = in6addr_any
        //
        if withUnsafePointer(&sin6, {sin6Ptr in
        Foundation.bind(listener_socket, UnsafePointer<sockaddr>(sin6Ptr), socklen_t(sizeof(sockaddr_in6)))
        }) < 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return 0
    }
    
    override func setHandler() {
        dispatch_source_set_event_handler(dispatch_source!) {
            var sin6: sockaddr_in6 = sockaddr_in6()
            var len: socklen_t = socklen_t(sizeof(sockaddr_in6))
            let client_sock = withUnsafeMutablePointer(&sin6) {sin6Ptr in
                accept(self.listener_socket, UnsafeMutablePointer<sockaddr>(sin6Ptr), &len)
            }
            
            var ip6_addr = sin6.sin6_addr
            var buf = [Int8](count: 48, repeatedValue: 0)
            inet_ntop(AF_INET6, &ip6_addr, &buf, 48)
            let ip6_addr_name = String.fromCString(&buf)
            NSLog("got request: ip=%@", ip6_addr_name!)
            
            self.connectionHandler?(client_sock, SocketAddress.IPv6(sin6))
        }
    }
}