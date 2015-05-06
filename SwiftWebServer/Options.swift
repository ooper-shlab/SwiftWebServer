//
//  Options.swift
//  SwiftWebServer
//
//  Created by 開発 on 2014/10/12.
//  Copyright (c) 2014年 nagata_kobo. All rights reserved.
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

class Options {
    private(set) var port: UInt16 = 8080
    private(set) var backlogs: Int32 = 16
    private(set) var staticBase: String = "/Library/WebServer/Documents"
    private(set) var types: [String: String] = [
        "html": "text/html",
        "htm": "text/html",
        "txt": "text/plain",
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
        var c: Int32 = 0
        var digit_optind: Int32 = 0

        OUTER_LOOP: while true {
            var this_option_optind = optind != 0 ? optind : 1
            var option_index: Int32 = 0
            let long_options: [option] = [
                option(name: "add", has_arg: required_argument, flag: nil, val: 0),
                option(name: "append", has_arg: required_argument, flag: nil, val: 0),
                option(name: "delete", has_arg: required_argument, flag: nil, val: 0),
                option(name: "verbose", has_arg: no_argument, flag: nil, val: 0),
                option(name: "create", has_arg: required_argument, flag: nil, val: "c"),
                option(name: "file", has_arg: required_argument, flag: nil, val: 0),
                option(name: nil, has_arg: 0, flag: nil, val: 0),
            ]

            c = getopt_long(Process.argc, Process.unsafeArgv, "abc:d:012", long_options, &option_index)

            switch c {
            case -1:
                break OUTER_LOOP
            case 0:
                var name = String.fromCString(long_options[Int(option_index)].name)
                print("option \(name)")
                if optarg != nil {
                    var optarg_name = String.fromCString(optarg)
                    print(" with arg \(optarg_name)")
                }
                println()

            case "0", "1", "2":
                if digit_optind != 0 && digit_optind != this_option_optind {
                    println("digits occur in two different argv-elements.")
                }
                digit_optind = this_option_optind
                println("option \(UnicodeScalar(UInt32(c)))")

            case "a":
                println("option a")

            case "b":
                println("option b")

            case "c":
                var optarg_name = String.fromCString(optarg)
                println("option c with value '\(optarg_name)'")

            case "d":
                var optarg_name = String.fromCString(optarg)
                println("option d with value '\(optarg_name)'")

            case "?":
                break

            default:
                var c_oct = String(c, radix: 8)
                println("?? getopt returned character code 0\(c_oct) ??")
            }
        }

        if optind < Process.argc {
            print("non-option ARGV-elements: ")
            while optind < Process.argc {
                let argv_name = String.fromCString(Process.unsafeArgv[Int(optind++)])
                print("\(argv_name) ")
            }
            println()
        }

    }
}