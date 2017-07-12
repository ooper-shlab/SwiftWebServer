//
//  HTTPConstants.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/21.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

let CR = UInt8(ascii: "\r")
let LF = UInt8(ascii: "\n")
let emptyLineData = Data(bytes: UnsafePointer<UInt8>([CR, LF, CR, LF]), count: 4)
