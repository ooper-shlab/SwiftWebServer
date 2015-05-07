//
//  OOPJSON.swift
//  SwiftWebServer
//
//  Created by 開発 on 2015/5/5.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

public enum JSON {
    case STRING(String)
    case NUMBER(Double)
    case BOOL(Bool)
    case OBJECT([String: JSON])
    case ARRAY([JSON])
    case NULL
}
//MARK: -
//MARK: type checks
extension JSON {
    public var isString: Bool {
        switch self {
        case STRING:
            return true
        default:
            return false
        }
    }
    public var isNumber: Bool {
        switch self {
        case NUMBER:
            return true
        default:
            return false
        }
    }
    public var isBool: Bool {
        switch self {
        case BOOL:
            return true
        default:
            return false
        }
    }
    public var isObject: Bool {
        switch self {
        case OBJECT(let val):
            return true
        default:
            return false
        }
    }
    public var isArray: Bool {
        switch self {
        case ARRAY:
            return true
        default:
            return false
        }
    }
    public var isNull: Bool {
        switch self {
        case NULL:
            return true
        default:
            return false
        }
    }
}
//MARK: -
//MARK: type conversions
extension JSON {
    public var asString: String? {
        switch self {
        case STRING(let val):
            return val
        default:
            return nil
        }
    }
    public var asNumber: Double? {
        switch self {
        case NUMBER(let val):
            return val
        default:
            return nil
        }
    }
    public var asBool: Bool? {
        switch self {
        case BOOL(let val):
            return val
        default:
            return nil
        }
    }
    public var asObject: [String: JSON]? {
        switch self {
        case OBJECT(let val):
            return val
        default:
            return nil
        }
    }
    public var asArray: [JSON]? {
        switch self {
        case ARRAY(let val):
            return val
        default:
            return nil
        }
    }
}
//MARK: -
//MARK: iterating
///Empty generator
public class JSONGenerator: GeneratorType {
    public func next() -> (String, JSON)? {
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
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case ARRAY(let val):
                assert(0..<val.count ~= index, "index out of range")
                    return val[index]
            default:
                fatalError("value is not a JSON.ARRAY")
            }
        }
        //mutating methods are not effective!!!
        mutating set {
            switch self {
            case ARRAY(var val):
                assert(0..<val.count ~= index, "index out of range")
                val[index] = newValue
                self = .ARRAY(val)
            default:
                fatalError("value is not a JSON.ARRAY")
            }
        }
    }
    public subscript(key: String) -> JSON? {
        get {
            switch self {
            case OBJECT(let val):
                return val[key]
            default:
                fatalError("value is not a JSON.OBJECT")
            }
        }
        //mutating methods are not effective!!!
        mutating set {
            switch self {
            case OBJECT(var val):
                assert(newValue != Optional<JSON>.None)
                val[key] = newValue!
                self = .OBJECT(val)
            default:
                fatalError("value is not a JSON.OBJECT")
            }
        }
    }
    public func generate() -> JSONGenerator {
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
//MARK: -
//MARK: literals
extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .NUMBER(Double(value))
    }
}
extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .NUMBER(value)
    }
}
extension JSON: StringLiteralConvertible {
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .STRING(value)
    }
    public init(stringLiteral value: StringLiteralType) {
        self = .STRING(value)
    }
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .STRING(value)
    }
}
extension JSON: StringInterpolationConvertible {
    public init(stringInterpolation strings: JSON...) {
        self = .STRING(reduce(lazy(strings).map {$0.description}, "", +))
    }
    public init<T>(stringInterpolationSegment expr: T) {
        self = .STRING(toString(expr))
    }
}
extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .BOOL(value)
    }
}
//Remember, `nil` can be ambiguous when treating JSON?
extension JSON: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .NULL
    }
}
extension JSON: ArrayLiteralConvertible {
//    typealias Element = JSON
    public init(arrayLiteral elements: JSON...) {
        self = .ARRAY(elements)
    }
}
extension JSON: DictionaryLiteralConvertible {
//    typealias Key = String
//    typealias Value = JSON
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dict: [String: JSON] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self = .OBJECT(dict)
    }
}
//MARK: -
//MARK: printing
extension JSON: Printable, DebugPrintable {
    public var description: String {
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
    public var debugDescription: String {
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
    //minimum JSON compliant
    static let escapePattern = "[\"\\\\\\p{Cc}]"
    static let escapeRegex = RegularExpression(pattern: escapePattern, options: nil, error: nil)!
    static func escape(val: String) -> String {
        let result = escapeRegex.stringByReplacingMatchesInString(val) {match, _ in
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
//MARK: -
//MARK: parsing
extension JSON {
    
    static let unescapeRegex = RegularExpression(pattern: JSON_ESCAPES, options: nil, error: nil)!
    static func unescape(var val: String) -> String {
        if val.hasPrefix("\"") && val.hasSuffix("\"") && count(val) >= 2 {
            val = val[val.startIndex.successor()..<val.endIndex.predecessor()]
        }
        //strict JSON
        let result = unescapeRegex.stringByReplacingMatchesInString(val) {match, _ in
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
    static let JSON_ESCAPES = "\\\\(?:[\"\\\\/rntbf]|u[dD][89abAB][0-9a-fA-F]{2}\\\\u[dD][c-fC-F][0-9a-fA-F]{2}|u[0-9a-fA-F]{4})"
    static let JSON_NUMBER = "-?(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:[eE][-+]?[0-9]+)?"
    static let JSON_STRING = "\"(?:"+JSON_ESCAPES+"|[^\\\\\"])*\""
    static let OPEN_BRACE = "\\{"
    static let CLOSE_BRACE = "\\}"
    static let OPEN_BRACKET = "\\["
    static let CLOSE_BRACKET = "\\]"
    static let JSON_LITERALS = JSON_STRING+"|"+JSON_NUMBER+"|true|false|null"
    static let FIRST_TOKEN = OPEN_BRACE+"|"+OPEN_BRACKET+"|"+JSON_LITERALS
    //
    static let LINE_COMMENT = "//.*(?:\\r\\n|\\r|\\n)"
    static let BLOCK_COMMENT = "/\\*(?:[^\\*]|\\*[^/])*\\*/"
    
    //Identifier letters for JavaScript (ECMAScript v3+)
    //Character sets/patterns
    static let ZWNJ = "\\u200C"
    static let ZWJ = "\\u200D"
    //Character sets
    static let UnicodeLetter = "\\p{Lu}\\p{Ll}\\p{Lt}\\p{Lm}\\p{Lo}\\p{Nl}"
    static let UnicodeCombiningMark = "\\p{Mn}\\p{Mc}"
    static let UnicodeDigit = "\\p{Nd}"
    static let UnicodeConnectorPunctuation = "\\p{Pc}"
    static let IdentifierStart = UnicodeLetter+"\\$_" //and \UnicodeEscapeSequence
    static let IdentifierPart = IdentifierStart+UnicodeCombiningMark+UnicodeDigit+UnicodeConnectorPunctuation+ZWNJ+ZWJ
    //Patterns
    static let UNICODE_ESCAPE_SEQUENCE = "\\\\u[0-9a-fA-F]{4}"
    static let IDENTIFIER_NAME = "(?:["+IdentifierStart+"]|"+UNICODE_ESCAPE_SEQUENCE+")(?:["+IdentifierPart+"]|"+UNICODE_ESCAPE_SEQUENCE+")*"
    
    public static func parseData(data: NSData) -> JSON? {
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        if string == nil {
            return nil
        } else {
            return JSON.parse(string!)
        }
    }
    static func isOpenBrace(token: String) -> Bool {
        return token == "{"
    }
    static func isOpenBracket(token: String) -> Bool {
        return token == "["
    }
    static func isCloseBrace(token: String) -> Bool {
        return token == "}"
    }
    static func isCloseBracket(token: String) -> Bool {
        return token == "]"
    }
    static func isStringToken(token: String) -> Bool {
        return token.hasSuffix("\"")
    }
    static func isTrueToken(token: String) -> Bool {
        return token == "true"
    }
    static func isFalseToken(token: String) -> Bool {
        return token == "false"
    }
    static func isNullToken(token: String) -> Bool {
        return token == "null"
    }
    
    public typealias JSONErrorHandler = NSError->Void
    
    static let preprocessedDafaultOptions: [String: AnyObject] = JSON.preprocessedOptions([:])
    public static func parse(string: String, var options: [String: AnyObject] = [:], onError: JSONErrorHandler? = nil) -> JSON? {
        if options.isEmpty {
            options = preprocessedDafaultOptions
        } else {
            options = processParseOptions(options)
        }
        let firstTokenRegex = options["firstTokenRegex"] as! NSRegularExpression
        var range = NSRange(0..<count(string.utf16))
        if let firstMatch = firstTokenRegex.firstMatchInString(string, options: nil, range: range) {
            let firstToken = (string as NSString).substringWithRange(firstMatch.rangeAtIndex(1))
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            return parseValue(firstToken, string, &range, options, onError)
        } else {
            onError?(JSONParseError("invalid JSON", string, range))
            return nil
        }
    }
    
    static let preprocessedSettingsOptions: [String: AnyObject] = JSON.preprocessedOptions([
        "comments": true,
        "omittableComma": true,
        "unquotedKey": true,
        "eofTerminates": true,
    ])
    public static func parseSettings(string: String, onError: JSONErrorHandler? = nil) -> JSON? {
        var range = NSRange(0..<count(string.utf16))
        return parseObject(string, &range, preprocessedSettingsOptions, onError)
    }
    
    public static func preprocessedOptions(options: [String: AnyObject]) -> [String: AnyObject] {
        var result = processParseOptions(options)
        result["preprocessed"] = true
        return result
    }
    
    /// valid options: type(default value)
    /// "preprocessed": Bool(false)
    /// "comments": Bool(false)
    /// "acceptsScalar": Bool(false)
    /// "omittableComma": Bool(false)
    /// "unquotedKey": Bool(false)
    /// "eofTerminates": Bool(false)
    /// "trailingComma": Bool(false)
    /// "duplicateKey": Bool(true)
    /// "firstTokenRegex": NSRegularExpression
    /// "firstValueRegex": NSRegularExpression
    /// "nextValueRegex": NSRegularExpression
    /// "firstPairRegex": NSRegularExpression
    /// "nextPairRegex": NSRegularExpression
    static func processParseOptions(options: [String: AnyObject]) -> [String: AnyObject] {
        if options["preprocessed"] as? Bool ?? false {
            if options["firstTokenRegex"] is NSRegularExpression
            && options["firstValueRegex"] is NSRegularExpression
            && options["nextValueRegex"] is NSRegularExpression
            && options["firstPairRegex"] is NSRegularExpression
            && options["nextPairRegex"] is NSRegularExpression
            {
                return options
            }
        }
        //Retrieve option
        let comments = options["comments"] as? Bool ?? false
        let SPACES = comments ? "(?:\\s|"+LINE_COMMENT+"|"+BLOCK_COMMENT+")*" : "\\s*"
        
        let acceptsScalar = options["acceptsScalar"] as? Bool ?? false
        let GLOBAL_FIRST_TOKEN = acceptsScalar ? FIRST_TOKEN : OPEN_BRACE+"|"+OPEN_BRACKET
        
        let omittableComma = options["omittableComma"] as? Bool ?? false
        let COMMA = omittableComma ? "(?:,"+SPACES+")?" : ","+SPACES
        
        let unquotedKey = options["unquotedKey"] as? Bool ?? false
        let KEY = unquotedKey ? "(?:"+JSON_STRING+"|"+IDENTIFIER_NAME+")" : JSON_STRING
        
        let eofTerminates = options["eofTerminates"] as? Bool ?? false
        let CLOSE_ARRAY = eofTerminates ? CLOSE_BRACKET+"|\\z" : CLOSE_BRACKET
        let CLOSE_OBJECT = eofTerminates ? CLOSE_BRACE+"|\\z" : CLOSE_BRACE
        
        let trailingComma = options["trailingComma"] as? Bool ?? false
        let TRAILING_COMMA = trailingComma ? "(?:,"+SPACES+")?" : ""
        
        //Generate RegularExpression objects
        let firstTokenPattern = "\\A"+SPACES+"("+GLOBAL_FIRST_TOKEN+")"
        let firstValuePattern = "\\A"+SPACES+"(?:"+TRAILING_COMMA+"("+CLOSE_ARRAY+")|("+FIRST_TOKEN+"))"
        let nextValuePattern = "\\A"+SPACES+"(?:"+TRAILING_COMMA+"("+CLOSE_ARRAY+")|"+COMMA+"("+FIRST_TOKEN+"))"
        let firstPairPattern = "\\A"+SPACES+"(?:"+TRAILING_COMMA+"("+CLOSE_OBJECT+")|("+KEY+")"+SPACES+":"+SPACES+"("+FIRST_TOKEN+"))"
        let nextPairPattern = "\\A"+SPACES+"(?:"+TRAILING_COMMA+"("+CLOSE_OBJECT+")|"+COMMA+"("+KEY+")"+SPACES+":"+SPACES+"("+FIRST_TOKEN+"))"
        var result = options
        result["firstTokenRegex"] = RegularExpression(pattern: firstTokenPattern, options: nil, error: nil)!
        result["firstValueRegex"] = RegularExpression(pattern: firstValuePattern, options: nil, error: nil)!
        result["nextValueRegex"] = RegularExpression(pattern: nextValuePattern, options: nil, error: nil)!
        result["firstPairRegex"] = RegularExpression(pattern: firstPairPattern, options: nil, error: nil)!
        result["nextPairRegex"] = RegularExpression(pattern: nextPairPattern, options: nil, error: nil)!
        return result
    }
    
    //range.location points to the next character of the firstToken.
    static func parseValue(firstToken: String, _ string: String, inout _ range: NSRange, _ options: [String: AnyObject], _ onError: JSONErrorHandler?) -> JSON? {
        if isOpenBrace(firstToken) {
            return parseObject(string, &range, options, onError)
        } else if isOpenBracket(firstToken) {
            return parseArray(string, &range, options, onError)
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
    
    static func parseArray(string: String, inout _ range: NSRange, _ options: [String: AnyObject], _ onError: JSONErrorHandler?) -> JSON? {
        var values: [JSON] = []
        let firstValueRegex = options["firstValueRegex"] as! NSRegularExpression
        let nextValueRegex = options["nextValueRegex"] as! NSRegularExpression
        if let firstMatch = firstValueRegex.firstMatchInString(string, options: nil, range: range) {
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            assert(firstMatch.numberOfRanges == 3)
            if firstMatch.rangeAtIndex(1).location != NSNotFound {
                return ARRAY(values)
            }
            let firstToken = (string as NSString).substringWithRange(firstMatch.rangeAtIndex(2))
            if let value = parseValue(firstToken, string, &range, options, onError) {
                values.append(value)
            } else {
                onError?(JSONParseError("invalid array", string, range))
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
            if let value = parseValue(nextToken, string, &range, options, onError) {
                values.append(value)
            } else {
                break
            }
        }
        onError?(JSONParseError("invalid array", string, range))
        return nil
    }
    
    static func parseObject(string: String, inout _ range: NSRange, _ options: [String: AnyObject], _ onError: JSONErrorHandler?) -> JSON? {
        var dict: [String: JSON] = [:]
        let firstPairRegex = options["firstPairRegex"] as! NSRegularExpression
        let nextPairRegex = options["nextPairRegex"] as! NSRegularExpression
        let duplicateKey = options["duplicateKey"] as? Bool ?? true //defaults true
        if let firstMatch = firstPairRegex.firstMatchInString(string, options: nil, range: range) {
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            assert(firstMatch.numberOfRanges == 4)
            if firstMatch.rangeAtIndex(1).location != NSNotFound {
                return OBJECT(dict)
            }
            let key = unescape((string as NSString).substringWithRange(firstMatch.rangeAtIndex(2)))
            let firstToken = (string as NSString).substringWithRange(firstMatch.rangeAtIndex(3))
            if let value = parseValue(firstToken, string, &range, options, onError) {
                dict[key] = value
            } else {
                onError?(JSONParseError("invalid object", string, range))
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
            if let value = parseValue(nextToken, string, &range, options, onError) {
                if dict[key] != nil && !duplicateKey {
                    //error
                    break
                }
                dict[key] = value
            } else {
                break
            }
        }
        onError?(JSONParseError("invalid object", string, range))
        return nil
    }
    
    static func JSONParseError(message: String, _ string: String, _ range: NSRange) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            "message": message
        ]
        return NSError(domain: "JSON.parse", code: 0, userInfo: userInfo)
    }
}
//MARK: -
//MARK: Equatable
extension JSON: Equatable {}
public func ==(lhs: JSON, rhs: JSON) -> Bool {
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