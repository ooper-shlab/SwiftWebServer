//
//  TCPListener.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/10/13.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

enum SocketAddress {
    case iPv4(sockaddr_in)
    case iPv6(sockaddr_in6)
    case sysError(errno: Int32)
    case error(NSError)
}

extension SocketAddress {
    init(sockaddrPtr: UnsafePointer<sockaddr>) {
        switch sockaddrPtr.pointee.sa_family {
        case sa_family_t(AF_INET):
            let sockaddr4Ptr = UnsafeRawPointer(sockaddrPtr).assumingMemoryBound(to: sockaddr_in.self)
            self = .iPv4(sockaddr4Ptr.pointee)
        case sa_family_t(AF_INET6):
            let sockaddr6Ptr = UnsafeRawPointer(sockaddrPtr).assumingMemoryBound(to: sockaddr_in6.self)
            self = .iPv6(sockaddr6Ptr.pointee)
        default:
            self = .sysError(errno: -1)
        }
    }
}

class TCPListener {
    fileprivate var listener_socket: Int32 = -1
    fileprivate var dispatch_source: DispatchSourceRead?
    
    var connectionHandler: ((Int32, SocketAddress)->Void)?
    
    static var queue: DispatchQueue = DispatchQueue.main
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
            dispatch_source!.cancel()
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
        if setsockopt(listener_socket, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size)) != 0 {
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
        
        dispatch_source = DispatchSource.makeReadSource(fileDescriptor: listener_socket, queue: listen_queue)
        if dispatch_source == nil {
            //error
            NSLog("error in %@:%d", #file, #line)
            return -1
        }
        return 0
    }
    
    func setHandler() {
    }
    
    func resume() {
        dispatch_source!.resume()
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
        sin.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        sin.sin_family = sa_family_t(AF_INET)
        sin.sin_port = htons(port)
        sin.sin_addr.s_addr = htonl(INADDR_ANY)
        //
        if withUnsafePointer(to: &sin, {sin4Ptr->Int32 in
            let sinPtr = UnsafeRawPointer(sin4Ptr).assumingMemoryBound(to: sockaddr.self)
            return Foundation.bind(listener_socket, sinPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
        }) < 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return 0
    }
    
    override func setHandler() {
        dispatch_source!.setEventHandler {
            var sin: sockaddr_in = sockaddr_in()
            var len: socklen_t = socklen_t(MemoryLayout<sockaddr_in>.size)
            let client_sock = withUnsafeMutablePointer(to: &sin) {sin4Ptr->Int32 in
                let sinPtr = UnsafeMutableRawPointer(sin4Ptr).assumingMemoryBound(to: sockaddr.self)
                return accept(self.listener_socket, sinPtr, &len)
            }
            
            let ip_addr = ntohl(sin.sin_addr.s_addr)
            NSLog("got request: ip=%08x", ip_addr)
            
            self.connectionHandler?(client_sock, SocketAddress.iPv4(sin))
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
        sin6.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        sin6.sin6_family = sa_family_t(AF_INET6)
        sin6.sin6_port = htons(port)
        sin6.sin6_addr = in6addr_any
        //
        if withUnsafePointer(to: &sin6, {sin6Ptr->Int32 in
            let sinPtr = UnsafeRawPointer(sin6Ptr).assumingMemoryBound(to: sockaddr.self)
            return Foundation.bind(listener_socket, sinPtr, socklen_t(MemoryLayout<sockaddr_in6>.size))
        }) < 0 {
            // Handle the error.
            SysErrorLog(errno)
            return -1
        }
        return 0
    }
    
    override func setHandler() {
        dispatch_source!.setEventHandler {
            var sin6: sockaddr_in6 = sockaddr_in6()
            var len: socklen_t = socklen_t(MemoryLayout<sockaddr_in6>.size)
            let client_sock = withUnsafeMutablePointer(to: &sin6) {sin6Ptr->Int32 in
                let sinPtr = UnsafeMutableRawPointer(sin6Ptr).assumingMemoryBound(to: sockaddr.self)
                return accept(self.listener_socket, sinPtr, &len)
            }
            
            var ip6_addr = sin6.sin6_addr
            var buf = [Int8](repeating: 0, count: 48)
            inet_ntop(AF_INET6, &ip6_addr, &buf, 48)
            let ip6_addr_name = String(cString: &buf)
            NSLog("got request: ip=%@", ip6_addr_name)
            
            self.connectionHandler?(client_sock, SocketAddress.iPv6(sin6))
        }
    }
}
