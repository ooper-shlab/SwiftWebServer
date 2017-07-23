//
//  OOPJSON.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/5.
//  Last update adapted to Swift 4 on 2017/7/23.
//  Copyright (c) 2015-2017 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

public enum JSON {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSON])
    case array([JSON])
    case null
}
//MARK: -
//MARK: type checks
extension JSON {
    public var isString: Bool {
        switch self {
        case .string:
            return true
        default:
            return false
        }
    }
    public var isNumber: Bool {
        switch self {
        case .number:
            return true
        default:
            return false
        }
    }
    public var isBool: Bool {
        switch self {
        case .bool:
            return true
        default:
            return false
        }
    }
    public var isObject: Bool {
        switch self {
        case .object:
            return true
        default:
            return false
        }
    }
    public var isArray: Bool {
        switch self {
        case .array:
            return true
        default:
            return false
        }
    }
    public var isNull: Bool {
        switch self {
        case .null:
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
        case .string(let val):
            return val
        default:
            return nil
        }
    }
    public var asNumber: Double? {
        switch self {
        case .number(let val):
            return val
        default:
            return nil
        }
    }
    public var asBool: Bool? {
        switch self {
        case .bool(let val):
            return val
        default:
            return nil
        }
    }
    public var asObject: [String: JSON]? {
        switch self {
        case .object(let val):
            return val
        default:
            return nil
        }
    }
    public var asArray: [JSON]? {
        switch self {
        case .array(let val):
            return val
        default:
            return nil
        }
    }
}
//MARK: -
//MARK: iterating
///Empty generator
open class JSONGenerator: IteratorProtocol {
    open func next() -> (String, JSON)? {
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
            let result = (String(index), array[index])
            index += 1
            return result
        }
    }
}
class JSONObjectGenerator: JSONGenerator {
    private var dictGenerator: DictionaryIterator<String, JSON>
    init(dict: [String: JSON]) {
        dictGenerator = dict.makeIterator()
    }
    override func next() -> (String, JSON)? {
        return dictGenerator.next()
    }
}
extension JSON: Sequence {
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case .array(let val):
                assert(0..<val.count ~= index, "index out of range")
                    return val[index]
            default:
                fatalError("value is not a JSON.ARRAY")
            }
        }
        //mutating methods are not effective!!!
        mutating set {
            switch self {
            case .array(var val):
                assert(0..<val.count ~= index, "index out of range")
                val[index] = newValue
                self = .array(val)
            default:
                fatalError("value is not a JSON.ARRAY")
            }
        }
    }
    public subscript(key: String) -> JSON? {
        get {
            switch self {
            case .object(let val):
                return val[key]
            default:
                fatalError("value is not a JSON.OBJECT")
            }
        }
        //mutating methods are not effective!!!
        mutating set {
            switch self {
            case .object(var val):
                assert(newValue != Optional<JSON>.none)
                val[key] = newValue!
                self = .object(val)
            default:
                fatalError("value is not a JSON.OBJECT")
            }
        }
    }
    public func makeIterator() -> JSONGenerator {
        switch self {
        case .string, .number, .bool:
            fatalError("Cannot iterate on STRING/NUMBER/BOOL")
        case .object(let val):
            return JSONObjectGenerator(dict: val)
        case .array(let val):
            return JSONArrayGenerator(array: val)
        case .null:
            return JSONGenerator()
        }
    }
}
//MARK: -
//MARK: literals
extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}
extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}
extension JSON: ExpressibleByStringLiteral {
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .string(value)
    }
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .string(value)
    }
}
//extension JSON: StringInterpolationConvertible {
//    public init(stringInterpolation strings: JSON...) {
//        self = .string(strings.lazy.map {$0.description}.reduce("", +))
//    }
//    public init<T>(stringInterpolationSegment expr: T) {
//        self = .string(String(describing: expr))
//    }
//}
extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}
//Remember, `nil` can be ambiguous when treating JSON?
extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}
extension JSON: ExpressibleByArrayLiteral {
//    typealias Element = JSON
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}
extension JSON: ExpressibleByDictionaryLiteral {
//    typealias Key = String
//    typealias Value = JSON
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dict: [String: JSON] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self = .object(dict)
    }
}
//MARK: -
//MARK: printing
extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .string(let val):
            return val
        case .number(let val):
            return String(format: "%.15g", val)
        case .bool(let val):
            return val ? "true": ""
        case .object(let val):
            return val.description
        case .array(let val):
            return val.description
        case .null:
            return ""
        }
    }
    public var debugDescription: String {
        switch self {
        case .string(let val):
            return "\"\(JSON.escape(val))\""
        case .number(let val):
            return String(format: "%.15g", val)
        case .bool(let val):
            return val.description
        case .object(let val):
            return "{" + val.lazy.map{"\"\(JSON.escape($0))\": \($1.debugDescription)"}.joined(separator: ", ") + "}"
        case .array(let val):
            return "[" + val.lazy.map{$0.debugDescription}.joined(separator: ", ") + "]"
        case .null:
            return "null"
        }
    }
    //minimum JSON compliant
    static let escapePattern = "[\"\\\\\\p{Cc}]"
    static let escapeRegex = try! OOPRegularExpression(pattern: escapePattern, options: []) {match, _ in
        let us = match.unicodeScalars[match.unicodeScalars.startIndex]
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
    static func escape(_ val: String) -> String {
        let result = escapeRegex.stringByReplacingMatchesInString(val)
        return result
    }
}
//MARK: -
//MARK: parsing
extension JSON {
    
    static let unescapeRegex = try! OOPRegularExpression(pattern: JSON_ESCAPES, options: []) {match, _ in
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
            if match.characters.count > 6 {
                let hi = (match as NSString).substring(with: NSRange(2..<6))
                let lo = (match as NSString).substring(with: NSRange(8..<12))
                value = (strtoul(hi, nil, 16) << 12 + strtoul(lo, nil, 16)) + 0x10000
            } else {
                let hex = (match as NSString).substring(with: NSRange(2..<6))
                value = strtoul(hex, nil, 16)
            }
            return String(describing: UnicodeScalar(UInt32(value)))
        }
    }
    static func unescape(_ val: String) -> String {
        var val = val
        if val.hasPrefix("\"") && val.hasSuffix("\"") && val.characters.count >= 2 {
            val = String(val[val.characters.index(after: val.startIndex)..<val.characters.index(before: val.endIndex)])
        }
        //strict JSON
        let result = unescapeRegex.stringByReplacingMatchesInString(val)
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
    
    public static func parseData(_ data: Data) -> JSON? {
        let string = String(data: data, encoding: .utf8)
        if string == nil {
            return nil
        } else {
            return JSON.parse(string!)
        }
    }
    static func isOpenBrace(_ token: String) -> Bool {
        return token == "{"
    }
    static func isOpenBracket(_ token: String) -> Bool {
        return token == "["
    }
    static func isCloseBrace(_ token: String) -> Bool {
        return token == "}"
    }
    static func isCloseBracket(_ token: String) -> Bool {
        return token == "]"
    }
    static func isStringToken(_ token: String) -> Bool {
        return token.hasSuffix("\"")
    }
    static func isTrueToken(_ token: String) -> Bool {
        return token == "true"
    }
    static func isFalseToken(_ token: String) -> Bool {
        return token == "false"
    }
    static func isNullToken(_ token: String) -> Bool {
        return token == "null"
    }
    
    public typealias JSONErrorHandler = (NSError)->Void
    
    static let preprocessedDafaultOptions: [String: Any] = JSON.preprocessedOptions([:])
    public static func parse(_ string: String, options: [String: Any] = [:], onError: JSONErrorHandler? = nil) -> JSON? {
        var options = options
        if options.isEmpty {
            options = preprocessedDafaultOptions
        } else {
            options = processParseOptions(options)
        }
        let firstTokenRegex = options["firstTokenRegex"] as! NSRegularExpression
        var range = NSRange(0..<string.utf16.count)
        if let firstMatch = firstTokenRegex.firstMatch(in: string, options: [], range: range) {
            let firstToken = (string as NSString).substring(with: firstMatch.range(at: 1))
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            return parseValue(firstToken, string, &range, options, onError)
        } else {
            onError?(JSONParseError("invalid JSON", string, range))
            return nil
        }
    }
    
    static let preprocessedSettingsOptions: [String: Any] = JSON.preprocessedOptions([
        "comments": true,
        "omittableComma": true,
        "unquotedKey": true,
        "eofTerminates": true,
    ])
    public static func parseSettings(_ string: String, onError: JSONErrorHandler? = nil) -> JSON? {
        var range = NSRange(0..<string.utf16.count)
        return parseObject(string, &range, preprocessedSettingsOptions, onError)
    }
    
    public static func preprocessedOptions(_ options: [String: Any]) -> [String: Any] {
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
    static func processParseOptions(_ options: [String: Any]) -> [String: Any] {
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
        result["firstTokenRegex"] = try! NSRegularExpression(pattern: firstTokenPattern, options: [])
        result["firstValueRegex"] = try! NSRegularExpression(pattern: firstValuePattern, options: [])
        result["nextValueRegex"] = try! NSRegularExpression(pattern: nextValuePattern, options: [])
        result["firstPairRegex"] = try! NSRegularExpression(pattern: firstPairPattern, options: [])
        result["nextPairRegex"] = try! NSRegularExpression(pattern: nextPairPattern, options: [])
        return result
    }
    
    //range.location points to the next character of the firstToken.
    static func parseValue(_ firstToken: String, _ string: String, _ range: inout NSRange, _ options: [String: Any], _ onError: JSONErrorHandler?) -> JSON? {
        if isOpenBrace(firstToken) {
            return parseObject(string, &range, options, onError)
        } else if isOpenBracket(firstToken) {
            return parseArray(string, &range, options, onError)
        } else if isStringToken(firstToken) {
            return self.string(unescape(firstToken))
        } else if isTrueToken(firstToken) {
            return bool(true)
        } else if isFalseToken(firstToken) {
            return bool(false)
        } else if isNullToken(firstToken) {
            return null
        } else {
            let value = Double(firstToken) ?? 0.0
            return number(value)
        }
    }
    
    static func parseArray(_ string: String, _ range: inout NSRange, _ options: [String: Any], _ onError: JSONErrorHandler?) -> JSON? {
        var values: [JSON] = []
        let firstValueRegex = options["firstValueRegex"] as! NSRegularExpression
        let nextValueRegex = options["nextValueRegex"] as! NSRegularExpression
        if let firstMatch = firstValueRegex.firstMatch(in: string, options: [], range: range) {
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            assert(firstMatch.numberOfRanges == 3)
            if firstMatch.range(at: 1).location != NSNotFound {
                return array(values)
            }
            let firstToken = (string as NSString).substring(with: firstMatch.range(at: 2))
            if let value = parseValue(firstToken, string, &range, options, onError) {
                values.append(value)
            } else {
                onError?(JSONParseError("invalid array", string, range))
                return nil
            }
        }
        while let nextMatch = nextValueRegex.firstMatch(in: string, options: [], range: range) {
            range.location += nextMatch.range.length
            range.length -= nextMatch.range.length
            assert(nextMatch.numberOfRanges == 3)
            if nextMatch.range(at: 1).location != NSNotFound {
                return array(values)
            }
            let nextToken = (string as NSString).substring(with: nextMatch.range(at: 2))
            if let value = parseValue(nextToken, string, &range, options, onError) {
                values.append(value)
            } else {
                break
            }
        }
        onError?(JSONParseError("invalid array", string, range))
        return nil
    }
    
    static func parseObject(_ string: String, _ range: inout NSRange, _ options: [String: Any], _ onError: JSONErrorHandler?) -> JSON? {
        var dict: [String: JSON] = [:]
        let firstPairRegex = options["firstPairRegex"] as! NSRegularExpression
        let nextPairRegex = options["nextPairRegex"] as! NSRegularExpression
        let duplicateKey = options["duplicateKey"] as? Bool ?? true //defaults true
        if let firstMatch = firstPairRegex.firstMatch(in: string, options: [], range: range) {
            range.location += firstMatch.range.length
            range.length -= firstMatch.range.length
            assert(firstMatch.numberOfRanges == 4)
            if firstMatch.range(at: 1).location != NSNotFound {
                return object(dict)
            }
            let key = unescape((string as NSString).substring(with: firstMatch.range(at: 2)))
            let firstToken = (string as NSString).substring(with: firstMatch.range(at: 3))
            if let value = parseValue(firstToken, string, &range, options, onError) {
                dict[key] = value
            } else {
                onError?(JSONParseError("invalid object", string, range))
                return nil
            }
        }
        while let nextMatch = nextPairRegex.firstMatch(in: string, options: [], range: range) {
            range.location += nextMatch.range.length
            range.length -= nextMatch.range.length
            assert(nextMatch.numberOfRanges == 4)
            if nextMatch.range(at: 1).location != NSNotFound {
                return object(dict)
            }
            let key = unescape((string as NSString).substring(with: nextMatch.range(at: 2)))
            let nextToken = (string as NSString).substring(with: nextMatch.range(at: 3))
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
    
    static func JSONParseError(_ message: String, _ string: String, _ range: NSRange) -> NSError {
        let userInfo: [String: Any] = [
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
    case (.array(let lval), .array(let rval)):
        return lval == rval
    case (.object(let lval), .object(let rval)):
        return lval == rval
    case (.string(let lval), .string(let rval)):
        return lval == rval
    case (.number(let lval), .number(let rval)):
        return lval == rval
    case (.bool(let lval), .bool(let rval)):
        return lval == rval
    case (.null, .null):
        return true
    default:
        return false
    }
}
