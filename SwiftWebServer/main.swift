//
//  main.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/12.
//  Copyright (c) 2014年 nagata_kobo. All rights reserved.
//

import Foundation

/*
https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/UsingSocketsandSocketStreams.html#//apple_ref/doc/uid/CH73-SW9
https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/UsingSocketsandSocketStreams.html#//apple_ref/doc/uid/CH73-SW10
*/
autoreleasepool {
    
    let listener4 = TCPListenerIPv4()
    if listener4 == nil {
        exit(EXIT_FAILURE)
    }
    let listener6 = TCPListenerIPv6()
    if listener6 == nil {
        exit(EXIT_FAILURE)
    }

    let connectionHandler = HTTPConnectionHandler()
    listener4!.connectionHandler = connectionHandler.handleConnection
    listener6!.connectionHandler = connectionHandler.handleConnection
    
    let listen_queue = TCPListener.queue
    dispatch_async(listen_queue) {
        NSLog("main queue works!")
    }
    NSLog("running main queue in %@:%d", __FILE__, __LINE__)
    //Run the main queue!
    dispatch_main()
    
    
}
