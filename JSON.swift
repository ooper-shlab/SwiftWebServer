//
//  OOPJSON.swift
//  SwiftWebServer
//
//  Created by 開発 on 2015/5/5.
//  Copyright (c) 2015年 nagata_kobo. All rights reserved.
//

import Foundation

enum JSON {
    case STRING(String)
    case NUMBER(Double)
    case BOOL(Bool)
    case OBJECT([String: JSON])
    case ARRAY([JSON])
    case NULL
}
extension JSON {
    var isString: Bool {
        switch self {
        case STRING:
            return true
        default:
            return false
        }
    }
    var isNumber: Bool {
        switch self {
        case NUMBER:
            return true
        default:
            return false
        }
    }
    var isBool: Bool {
        switch self {
        case BOOL:
            return true
        default:
            return false
        }
    }
    var isObject: Bool {
        switch self {
        case OBJECT(let val):
            return true
        default:
            return false
        }
    }
    var isArray: Bool {
        switch self {
        case ARRAY:
            return true
        default:
            return false
        }
    }
    var isNull: Bool {
        switch self {
        case NULL:
            return true
        default:
            return false
        }
    }
}
extension JSON {
    var asString: String? {
        switch self {
        case STRING(let val):
            return val
        default:
            return nil
        }
    }
    var asNumber: Double? {
        switch self {
        case NUMBER(let val):
            return val
        default:
            return nil
        }
    }
    var asBool: Bool? {
        switch self {
        case BOOL(let val):
            return val
        default:
            return nil
        }
    }
    var asObject: [String: JSON]? {
        switch self {
        case OBJECT(let val):
            return val
        default:
            return nil
        }
    }
    var asArray: [JSON]? {
        switch self {
        case ARRAY(let val):
            return val
        default:
            return nil
        }
    }
}
///Empty generator
class JSONGenerator: GeneratorType {
    func next() -> (String, JSON)? {
        return nil
    }
}
class JSONArrayGenerator: JSONGenerator {
    private var array: [JSON]
    private var index: Int = 0
    init(array: [JSON]) {
        self.array = array
        index = 0
    }
    override func next() -> (String, JSON)? {
        if index >= array.count {
            return nil
        } else {
            return (String(index), array[index++])
        }
    }
}
class JSONObjectGenerator: JSONGenerator {
    private var dictGenerator: DictionaryGenerator<String, JSON>
    init(dict: [String: JSON]) {
        dictGenerator = dict.generate()
    }
    override func next() -> (String, JSON)? {
        return dictGenerator.next()
    }
}
extension JSON: SequenceType {
    subscript(index: Int) -> JSON? {
        get {
            switch self {
            case ARRAY(let val):
                if 0..<val.count ~= index {
                    return val[index]
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        ///mutating methods are not effective!!!
        mutating set {
            switch self {
            case ARRAY(var val):
                if 0..<val.count ~= index {
                    assert(newValue != nil, "cannot assign Swift nil, use JSON.NULL instead")
                    val[index] = newValue!
                    self = .ARRAY(val)
                } else {
                    fatalError("index out of range")
                }
            default:
                fatalError("value is not a JSON.ARRAY")
            }
        }
    }
    subscript(key: String) -> JSON? {
        get {
            switch self {
            case OBJECT(let val):
                return val[key]
            default:
                return nil
            }
        }
        ///mutating methods are not effective!!!
        mutating set {
            switch self {
            case OBJECT(var val):
                assert(newValue != nil, "cannot assign Swift nil, use JSON.NULL instead")
                val[key] = newValue!
                self = .OBJECT(val)
            default:
                fatalError("value is not a OBJECT")
            }
        }
    }
    func generate() -> JSONGenerator {
        switch self {
        case STRING, NUMBER, BOOL:
            fatalError("Cannot iterate on STRING/NUMBER/BOOL")
        case OBJECT(let val):
            return JSONObjectGenerator(dict: val)
        case ARRAY(let val):
            return JSONArrayGenerator(array: val)
        case NULL:
            return JSONGenerator()
        }
    }
}
extension JSON: IntegerLiteralConvertible {
    init(integerLiteral value: IntegerLiteralType) {
        self = .NUMBER(Double(value))
    }
}
extension JSON: FloatLiteralConvertible {
    init(floatLiteral value: FloatLiteralType) {
        self = .NUMBER(value)
    }
}
extension JSON: StringLiteralConvertible {
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .STRING(value)
    }
    init(stringLiteral value: StringLiteralType) {
        self = .STRING(value)
    }
    init(unicodeScalarLiteral value: StringLiteralType) {
        self = .STRING(value)
    }
}
extension JSON: StringInterpolationConvertible {
    init(stringInterpolation strings: JSON...) {
        self = .STRING(reduce(lazy(strings).map {$0.description}, "", +))
    }
    init<T>(stringInterpolationSegment expr: T) {
        self = .STRING(toString(expr))
    }
}
extension JSON: BooleanLiteralConvertible {
    init(booleanLiteral value: BooleanLiteralType) {
        self = .BOOL(value)
    }
}
extension JSON: NilLiteralConvertible {
    init(nilLiteral: ()) {
        self = .NULL
    }
}
extension JSON: ArrayLiteralConvertible {
//    typealias Element = JSON
    init(arrayLiteral elements: JSON...) {
        self = .ARRAY(elements)
    }
}
extension JSON: DictionaryLiteralConvertible {
//    typealias Key = String
//    typealias Value = JSON
    init(dictionaryLiteral elements: (String, JSON)...) {
        var dict: [String: JSON] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self = .OBJECT(dict)
    }
}
//MARK: printing
extension JSON: Printable, DebugPrintable {
    var description: String {
        switch self {
        case STRING(let val):
            return val
        case NUMBER(let val):
            return String(format: "%.15g", val)
        case BOOL(let val):
            return val ? "true": ""
        case OBJECT(let val):
            return val.description
        case ARRAY(let val):
            return val.description
        case NULL:
            return ""
        }
    }
    var debugDescription: String {
        switch self {
        case STRING(let val):
            return "\"\(JSON.escape(val))\""
        case NUMBER(let val):
            return String(format: "%.15g", val)
        case BOOL(let val):
            return val.description
        case OBJECT(let val):
            return "{" + ", ".join(lazy(val).map{"\"\(JSON.escape($0))\": \($1.debugDescription)"}) + "}"
        case ARRAY(let val):
            return "[" + ", ".join(lazy(val).map{$0.debugDescription}) + "]"
        case NULL:
            return "null"
        }
    }
    static func escape(val: String) -> String {
        //minimum JSON compliant
        let pattern = "[\"\\\\\\p{Cc}]"
        let regex = RegularExpression(pattern: pattern, options: nil, error: nil)!
        let result = regex.stringByReplacingMatchesInString(val) {match, _ in
            var us = match.unicodeScalars[match.unicodeScalars.startIndex]
            switch us {
            case "\r":
                return "\\r"
            case "\n":
                return "\\n"
            case "\t":
                return "\\t"
            case "\u{8}":
                return "\\b"
            case "\u{c}":
                return "\\f"
            case "\"":
                return "\\\""
            case "\\":
                return "\\\\"
            default:
                let ch = us.value
                if ch < 0x10000 {
                    return String(format: "\\u%04x", ch)
                } else {
                    let hi = ((ch-0x10000) >> 12) + 0xD800
                    let lo = (ch & 0x3FF) + 0xDC00
                    return String(format: "\\u%04x\\u%04x", hi, lo)
                }
            }
        }
        return result
    }
}
//MARK: parsing
extension JSON {
    
    static func unescape(var val: String) -> String {
        if val.hasPrefix("\"") && val.hasSuffix("\"") && count(val) >= 2 {
            val = val[val.startIndex.successor()..<val.endIndex.predecessor()]
        }
        //strict JSON
        let pattern = JSON_ESCAPES
        let regex = RegularExpression(pattern: pattern, options: nil, error: nil)!
        let result = regex.stringByReplacingMatchesInString(val) {match, _ in
            switch match {
            case "\\r":
                return "\r"
            case "\\n":
                return "\n"
            case "\\t":
                return "\t"
            case "\\b":
                return "\u{8}"
            case "\\f":
                return "\u{c}"
            case "\\\"":
                return "\""
            case "\\\\":
                return "\\"
            case "\\/":
                return "/"
            default:
                let value: UInt
                if count(match) > 6 {
                    let hi = (match as NSString).substringWithRange(NSRange(2..<6))
                    let lo = (match as NSString).substringWithRange(NSRange(8..<12))
                    value = (strtoul(hi, nil, 16) << 12 + strtoul(lo, nil, 16)) + 0x10000
                } else {
                    let hex = (match as NSString).substringWithRange(NSRange(2..<6))
                    value = strtoul(hex, nil, 16)
                }
                return String(UnicodeScalar(UInt32(value)))
            }
        }
        return result
    }
    
    //JSON parsing patterns
    private static let JSON_ESCAPES = "\\\\(?:[\"\\\\/rntbf]|u[dD][89abAB][0-9a-fA-F]{2}\\\\u[dD][c-fC-F][0-9a-fA-F]{2}|u[0-9a-fA-F]{4})"
    private static let SPACES = "\\s*"
    private static let JSON_NUMBER = "-?(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][-+]?[0-9]+)?"
    private static let JSON_STRING = "\"(?:"+JSON_ESCAPES+"|[^\\\\\"])*\""
    private static let OPEN_BRACE = "\\{"
    private static let CLOSE_BRACE = "\\}"
    private static let OPEN_BRACKET = "\\["
    private static let CLOSE_BRACKET = "\\]"
    private static let JSON_LITERALS = JSON_STRING+"|"+JSON_NUMBER+"|true|false|null"
    private static let FIRST_TOKEN = OPEN_BRACE+"|"+OPEN_BRACKET+"|"+JSON_LITERALS
    private static let GLOBAL_FIRST_TOKEN = OPEN_BRACE+"|"+OPEN_BRACKET
    
    static func parseData(data: NSData) -> JSON? {
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        if string == nil {
            return nil
        } else {
            return JSON.parse(string!)
        }
    }
    private static func isOpenBrace(token: String) -> Bool {
        return token == "{"
    }
    private static func isOpenBracket(token: String) -> Bool {
        return token == "["
    }
    private static func isCloseBrace(token: String) -> Bool {
        return token == "}"
    }
    private static func isCloseBracket(token: String) -> Bool {
        return token == "]"
    }
    private static func isStringToken(token: String) -> Bool {
        return token.hasSuffix("\"")
    }
    private static func isTrueToken(token: String) -> Bool {
        return token == "true"
    }
    private static func isFalseToken(token: String) -> Bool {
        return token == "false"
    }
    private static func isNullToken(token: String) -> Bool {
        return token == "null"
    }
    
    typealias JSONErrorHandler = NSError->Void
    
    private static let firstTokenPattern = "^"+SPACES+"("+FIRST_TOKEN+")"
    private static let firstTokenRegex = RegularExpression(pattern: firstTokenPattern, options: nil, error: nil)!
    static func parse(string: String, onError: JSONErrorHandler? = nil) -> JSON? {
        var range = NSRange(0..<count(string.utf16))
        if let firstMatch = firstTokenRegex.firstMatchInString(string, options: nil, range: range) {
            let firstToken = (string as NSString).substringWithRange(firstMatch.rangeAtIndex(1))
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            return parseValue(firstToken, string, &range, onError)
        } else {
            if let errorHandler = onError {
                let userInfo: [NSObject: AnyObject] = [:]
                let error = NSError(domain: "JSON", code: 0, userInfo: userInfo)
                errorHandler(error)
            }
            return nil
        }
    }
    
    //range.location points to the next character of the firstToken.
    private static func parseValue(firstToken: String, _ string: String, inout _ range: NSRange, _ onError: JSONErrorHandler?) -> JSON? {
        if isOpenBrace(firstToken) {
            return parseObject(string, &range, onError)
        } else if isOpenBracket(firstToken) {
            return parseArray(string, &range, onError)
        } else if isStringToken(firstToken) {
            return STRING(unescape(firstToken))
        } else if isTrueToken(firstToken) {
            return BOOL(true)
        } else if isFalseToken(firstToken) {
            return BOOL(false)
        } else if isNullToken(firstToken) {
            return NULL
        } else {
            let value = (firstToken as NSString).doubleValue
            return NUMBER(value)
        }
    }
    
    private static let firstValuePattern = "^"+SPACES+"(?:("+CLOSE_BRACKET+")|("+FIRST_TOKEN+"))"
    private static let firstValueRegex = RegularExpression(pattern: firstValuePattern, options: nil, error: nil)!
    private static let nextValuePattern = "^"+SPACES+"(?:("+CLOSE_BRACKET+")|,"+SPACES+"("+FIRST_TOKEN+"))"
    private static let nextValueRegex = RegularExpression(pattern: nextValuePattern, options: nil, error: nil)!
    private static func parseArray(string: String, inout _ range: NSRange, _ onError: JSONErrorHandler?) -> JSON? {
        var values: [JSON] = []
        if let firstMatch = firstValueRegex.firstMatchInString(string, options: nil, range: range) {
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            assert(firstMatch.numberOfRanges == 3)
            if firstMatch.rangeAtIndex(1).location != NSNotFound {
                return ARRAY(values)
            }
            let firstToken = (string as NSString).substringWithRange(firstMatch.rangeAtIndex(2))
            if let value = parseValue(firstToken, string, &range, onError) {
                values.append(value)
            } else {
                return nil
            }
        }
        while let nextMatch = nextValueRegex.firstMatchInString(string, options: nil, range: range) {
            range.location += nextMatch.range.length
            range.length -= nextMatch.range.length
            assert(nextMatch.numberOfRanges == 3)
            if nextMatch.rangeAtIndex(1).location != NSNotFound {
                return ARRAY(values)
            }
            let nextToken = (string as NSString).substringWithRange(nextMatch.rangeAtIndex(2))
            if let value = parseValue(nextToken, string, &range, onError) {
                values.append(value)
            } else {
                return nil
            }
        }
        if let errorHandler = onError {
            let userInfo: [NSObject: AnyObject] = [:]
            let error = NSError(domain: "JSON", code: 0, userInfo: userInfo)
            errorHandler(error)
        }
        return nil
    }
    
    private static let firstPairPattern = "^"+SPACES+"(?:("+CLOSE_BRACE+")|("+JSON_STRING+")"+SPACES+":"+SPACES+"("+FIRST_TOKEN+"))"
    private static let firstPairRegex = RegularExpression(pattern: firstPairPattern, options: nil, error: nil)!
    private static let nextPairPattern = "^"+SPACES+"(?:("+CLOSE_BRACE+")|,"+SPACES+"("+JSON_STRING+")"+SPACES+":"+SPACES+"("+FIRST_TOKEN+"))"
    private static let nextPairRegex = RegularExpression(pattern: nextPairPattern, options: nil, error: nil)!
    private static func parseObject(string: String, inout _ range: NSRange, _ onError: JSONErrorHandler?) -> JSON? {
        var dict: [String: JSON] = [:]
        if let firstMatch = firstPairRegex.firstMatchInString(string, options: nil, range: range) {
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            assert(firstMatch.numberOfRanges == 4)
            if firstMatch.rangeAtIndex(1).location != NSNotFound {
                return OBJECT(dict)
            }
            let key = unescape((string as NSString).substringWithRange(firstMatch.rangeAtIndex(2)))
            let firstToken = (string as NSString).substringWithRange(firstMatch.rangeAtIndex(3))
            if let value = parseValue(firstToken, string, &range, onError) {
                if dict[key] != nil {
                    //error
                    return nil
                }
                dict[key] = value
            } else {
                return nil
            }
        }
        while let nextMatch = nextPairRegex.firstMatchInString(string, options: nil, range: range) {
            range.location += nextMatch.range.length
            range.length -= nextMatch.range.length
            assert(nextMatch.numberOfRanges == 4)
            if nextMatch.rangeAtIndex(1).location != NSNotFound {
                return OBJECT(dict)
            }
            let key = unescape((string as NSString).substringWithRange(nextMatch.rangeAtIndex(2)))
            let nextToken = (string as NSString).substringWithRange(nextMatch.rangeAtIndex(3))
            if let value = parseValue(nextToken, string, &range, onError) {
                if dict[key] != nil {
                    //error
                    return nil
                }
                dict[key] = value
            } else {
                return nil
            }
        }
        if let errorHandler = onError {
            let userInfo: [NSObject: AnyObject] = [:]
            let error = NSError(domain: "JSON", code: 0, userInfo: userInfo)
            errorHandler(error)
        }
        return nil
    }
}
extension JSON: Equatable {}
func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.ARRAY(let lval), .ARRAY(let rval)):
        return lval == rval
    case (.OBJECT(let lval), .OBJECT(let rval)):
        return lval == rval
    case (.STRING(let lval), .STRING(let rval)):
        return lval == rval
    case (.NUMBER(let lval), .NUMBER(let rval)):
        return lval == rval
    case (.BOOL(let lval), .BOOL(let rval)):
        return lval == rval
    case (.NULL, .NULL):
        return true
    default:
        return false
    }
}