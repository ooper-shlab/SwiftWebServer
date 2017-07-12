//
//  NSRegularExpression+.swift
//  OOPUtils
//
//  Created by 開発 on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension NSRegularExpression {
    
    func matches(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        return matches(string, options: options, range: NSRange(0..<string.utf16.count))
    }
    
    func matches(_ string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> Bool {
        return numberOfMatches(in: string, options: options, range: range) > 0
    }
}
