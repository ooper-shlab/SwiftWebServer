//
//  OOPRegularExpression.swift
//  SwiftWebServer
//
//  Created by 開発 on 2015/5/5.
//  Copyright (c) 2015年 nagata_kobo. All rights reserved.
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
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions = nil, withBlock block: ReplacementBlock) -> String {
        let range = NSRange(0..<count(string.utf16))
        return self.stringByReplacingMatchesInString(string, options: options, range: range, withBlock: block)
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, withSimpleBlock block: SimpleReplacementBlock) -> String {
        replacementBlock = {result,string,offset,_ in
            var matchedString = (string as NSString).substringWithRange(result.range)
            return block(matchedString, offset)
        }
        let result = super.stringByReplacingMatchesInString(string, options: options, range: range, withTemplate: "")
        replacementBlock = nil
        return result
    }
    
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions = nil, withSimpleBlock block: SimpleReplacementBlock) -> String {
        let range = NSRange(0..<count(string.utf16))
        return self.stringByReplacingMatchesInString(string, options: options, range: range, withSimpleBlock: block)
    }
}
