//
//  OOPRegularExpression.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/5.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

class RegularExpression: NSRegularExpression {
    
    typealias ReplacementBlock = (NSTextCheckingResult, String, Int, String)->String
    typealias SimpleReplacementBlock = (String, Int)->String
    
    private var replacementBlock: ReplacementBlock?
    override func replacementStringForResult(result: NSTextCheckingResult, inString string: String, offset: Int, template templ: String) -> String {
        if let replacement = replacementBlock {
            return replacement(result, string, offset, templ)
        } else {
            return super.replacementStringForResult(result, inString: string, offset: offset, template: templ)
        }
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, withBlock block: ReplacementBlock) -> String {
        replacementBlock = block
        let result = super.stringByReplacingMatchesInString(string, options: options, range: range, withTemplate: "")
        replacementBlock = nil
        return result
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions = [], withBlock block: ReplacementBlock) -> String {
        let range = NSRange(0..<string.utf16.count)
        return self.stringByReplacingMatchesInString(string, options: options, range: range, withBlock: block)
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, withSimpleBlock block: SimpleReplacementBlock) -> String {
        replacementBlock = {result,string,offset,_ in
            let matchedString = (string as NSString).substringWithRange(result.range)
            return block(matchedString, offset)
        }
        let result = super.stringByReplacingMatchesInString(string, options: options, range: range, withTemplate: "")
        replacementBlock = nil
        return result
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions = [], withSimpleBlock block: SimpleReplacementBlock) -> String {
        let range = NSRange(0..<string.utf16.count)
        return self.stringByReplacingMatchesInString(string, options: options, range: range, withSimpleBlock: block)
    }
    
    func matches(string: String, options: NSMatchingOptions = []) -> Bool {
        return matches(string, options: options, range: NSRange(0..<string.utf16.count))
    }
    
    func matches(string: String, options: NSMatchingOptions = [], range: NSRange) -> Bool {
        return numberOfMatchesInString(string, options: options, range: range) > 0
    }
}
