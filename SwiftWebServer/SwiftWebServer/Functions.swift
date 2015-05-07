//
//  Functions.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/13.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation
func SysErrorLog(err: errno_t, file: String = __FILE__, line: Int = __LINE__) {
    let errStr = String.fromCString(strerror(errno))
    NSLog("%@(%d) in %@:%d", errStr!, errno, file, line)
}
