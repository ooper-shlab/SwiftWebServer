//
//  Functions.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/10/13.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation
func SysErrorLog(_ err: errno_t, file: String = #file, line: Int = #line) {
    let errStr = String(cString: strerror(errno))
    NSLog("%@(%d) in %@:%d", errStr, errno, file, line)
}
