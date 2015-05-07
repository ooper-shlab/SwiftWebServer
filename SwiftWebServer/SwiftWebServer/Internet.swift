//
//  Internet.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/13.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

func htons(val: UInt16) -> UInt16 {
    //Network order is big-endian.
    return val.bigEndian
}

func htonl(val: UInt32) -> UInt32 {
    //Network order is big-endian.
    return val.bigEndian
}

func ntohs(val: UInt16) -> UInt16 {
    return UInt16(bigEndian: val)
}

func ntohl(val: UInt32) -> UInt32 {
    return UInt32(bigEndian: val)
}

//#define	INADDR_ANY		(u_int32_t)0x00000000
let INADDR_ANY = in_addr_t(0x00000000)
