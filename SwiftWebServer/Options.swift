//
//  Options.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/10/12.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension Int32: UnicodeScalarLiteralConvertible {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self = Int32(UInt32(value))
    }
}

func ~=(ch: UnicodeScalar, val: Int32) -> Bool {
    return UInt32(ch) == UInt32(val)
}

/// Read command line options & config files, and keep settings as properties
/// Valid options
///
/// -b
/// --static-base
///     base directory path for static documents
/// -p
/// --port
///     port number
/// -t
/// --types
///     mime/types, separated by comma, paired with colon
/// -d
/// --defaults
///     default index file, separated by comma
/// -c
/// --config
///     specify configuration file
///
class Options {
    private(set) var port: UInt16 = 8080
    private(set) var backlogs: Int32 = 16
    private(set) var staticBase: String = "/Library/WebServer/Documents"
    private(set) var types: [String: String] = [
        "html": "text/html",
        "htm": "text/html",
        "txt": "text/plain",
        "js": "text/javascript",
        "css": "text/css",
        "png": "image/png",
        "jpg": "image/jpg",
        "jpeg": "image/jpg",
        "gif": "image/gif",
        "ico": "image/vnd.microsoft.icon"
    ]
    private(set) var defaults: [String] = [
        "index.html",
        "index.htm",
    ]
    
    private(set) static var instance = Options()
    
    private init() {
        let shortopts = "b:p:t:d:c:"
        let longopts: [GetoptLong.OptionsType] = [
            ("static-base", true, false, "b"),
            ("port", true, false, "p"),
            ("types", true, false, "t"),
            ("defaults", true, false, "d"),
            ("config", true, false, "c"),
        ]
        let getopt = GetoptLong(shortopts: shortopts, longopts: longopts)
        if let config = getopt.option("c") {
            //TODO: load config file
            print(config)
        }
        //All command line options overrides the settings in the config file
        if let staticBase = getopt.option("b") {
            self.staticBase = staticBase
        }
        if let portStr = getopt.option("p"), port = Int(portStr)
            where port >= 0 && port < Int(UInt16.max) {
                self.port = UInt16(port)
        }
        if let types = getopt.option("types") {
            self.types = types.componentsSeparatedByString(",").reduce([:]) {dict, pair in
                var result = dict
                if let sep = pair.rangeOfString(":", options: []) {
                    let key = pair.substringToIndex(sep.startIndex)
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    let value = pair.substringFromIndex(sep.endIndex)
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    result[key] = value
                }
                return result
            }
        }
        if let defaults = getopt.option("d") {
            self.defaults = defaults.componentsSeparatedByString(",").map{
                $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
    }
}