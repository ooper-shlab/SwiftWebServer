//
//  Internet.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/10/13.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

func htons(_ val: UInt16) -> UInt16 {
    //Network order is big-endian.
    return val.bigEndian
}

func htonl(_ val: UInt32) -> UInt32 {
    //Network order is big-endian.
    return val.bigEndian
}

func ntohs(_ val: UInt16) -> UInt16 {
    return UInt16(bigEndian: val)
}

func ntohl(_ val: UInt32) -> UInt32 {
    return UInt32(bigEndian: val)
}

//#define	INADDR_ANY		(u_int32_t)0x00000000
let INADDR_ANY = in_addr_t(0x00000000)
