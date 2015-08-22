//
//  NSRegularExpression+.swift
//  OOPUtils
//
//  Created by 開発 on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension NSRegularExpression {
    
    func matches(string: String, options: NSMatchingOptions = []) -> Bool {
        return matches(string, options: options, range: NSRange(0..<string.utf16.count))
    }
    
    func matches(string: String, options: NSMatchingOptions = [], range: NSRange) -> Bool {
        return numberOfMatchesInString(string, options: options, range: range) > 0
    }
}
