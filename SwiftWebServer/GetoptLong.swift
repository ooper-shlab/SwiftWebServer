//
//  GetOptLong.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2014/12/16.
//  Copyright (c) 2014-2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

public class GetoptLong {
    public typealias OptionsType = (name: String, hasArg: Bool, argIsOptional: Bool, key: String)
    public typealias ArgumentType = (value: String, isDefault: Bool)
    enum ErrorType {
        case MissingArg //Cannot find an argument for the option.
        case NotOption //begins with "--" or "-", but does not contain option characters.
    }
    
    var argv: [String] = []
    
    var shortopts: [String: OptionsType] = [:]
    var longopts: [String: OptionsType] = [:]
    
    var optargs: [String: ArgumentType] = [:]
    var nonOptionsArgs: [String] = []
    var errors: [(arg: String, error: ErrorType)] = []
    
    /// See man page of getopt for shortopts, getopt_long for longopts
    public init(shortopts: String, longopts: [OptionsType]) {
        for var index = shortopts.startIndex; index < shortopts.endIndex; ++index {
            var key = String(shortopts[index])
            let next = index.successor()
            var hasArg = false
            var argIsOptional = false
            if next < shortopts.endIndex && shortopts[next] == ":" {
                index = next
                hasArg = true
                let nextToNext = next.successor()
                if nextToNext < shortopts.endIndex && shortopts[nextToNext] == ":" {
                    argIsOptional = true
                    index = nextToNext
                }
            }
            self.shortopts[key] = (key, hasArg, argIsOptional, key)
        }
        for longopt in longopts {
            self.longopts[longopt.name] = longopt
        }
        argv = Array(Process.arguments[1..<Process.arguments.count])
    }
    
    private var processed: Bool = false
    
    private func processOptions() {
        if processed {return}
        var optionFinished = false
        for var i = 0; i < argv.count; ++i {
            let arg = argv[i]
            if optionFinished {
                nonOptionsArgs.append(arg)
            } else if arg == "--" {
                optionFinished = true
            } else if arg.hasPrefix("--") {
                let n = processLongOption(i, arg)
                if n >= 0 {i += n}
            } else if arg == "-" {
                nonOptionsArgs.append(arg)
            } else if arg.hasPrefix("-") {
                let n = processShortOption(i, arg)
                if n >= 0 {i += n}
            } else {
                nonOptionsArgs.append(arg)
            }
        }
        processed = true
    }
    
    private func processLongOption(i: Int, _ arg: String) -> Int {
        let argName = arg.substringFromIndex(advance(arg.startIndex, 2))
        if let opt = longopts[argName] {
            if opt.hasArg {
                if i + 1 < argv.count && !isOption(argv[i + 1]) {
                    optargs[opt.key] = (argv[i + 1], false)
                    return 1    //skip 1 arg
                } else {
                    errors.append((arg: arg, error: ErrorType.MissingArg))
                    return -1
                }
            } else {
                optargs[opt.key] = ("", true)  //default value
            }
        } else {
            errors.append((arg: arg, error: ErrorType.NotOption))
        }
        return 0
    }
    
    private func isOption(arg: String) -> Bool {
        return arg != "-" && arg.hasPrefix("-")
    }
    
    private func processShortOption(i: Int, _ arg: String) -> Int {
        let argName = arg.substringFromIndex(advance(arg.startIndex, 1))
        //temporal restriction
        if count(argName) > 1 {
            for var index = argName.startIndex; index < argName.endIndex; ++index {
                var optChar = String(argName[index])
                if let opt = shortopts[optChar] {
                    if opt.hasArg {
                        if index.successor() < argName.endIndex {
                            optargs[opt.key] = (argName.substringFromIndex(index.successor()), false)
                            return 0    //skip 0 arg
                        } else if i + 1 < argv.count && !isOption(argv[i + 1]) {
                            optargs[opt.key] = (argv[i + 1], false)
                            return 1    //skip 1 arg
                        } else if opt.argIsOptional {
                            optargs[opt.key] = ("", true)
                            return 0
                        } else {
                            let error = (arg: optChar, error: ErrorType.MissingArg)
                            errors.append(error)
                            return -1
                        }
                    } else {
                        optargs[opt.key] = ("", true)  //default value
                        return 0
                    }
                } else {
                    let error = (arg: optChar, error: ErrorType.NotOption)
                    errors.append(error)
                    return -1
                }
            }
        }
        if let opt = shortopts[argName] {
            if opt.hasArg {
                if i + 1 < argv.count && !isOption(argv[i + 1]) {
                    optargs[opt.key] = (argv[i + 1], false)
                    return 1    //skip 1 arg
                } else if opt.argIsOptional {
                    optargs[opt.key] = ("", true)
                    return 0
                } else {
                    errors.append((arg: arg, error: ErrorType.MissingArg))
                    return -1
                }
            } else {
                optargs[opt.key] = ("", true)  //default value
            }
        } else {
            errors.append((arg: arg, error: ErrorType.NotOption))
        }
        return 0
    }

    /// Returns args without options
    public var args: [String] {
        self.processOptions()
        return self.nonOptionsArgs
    }
    
    public var options: [String: ArgumentType] {
        self.processOptions()
        return self.optargs
    }
    
    /// Returns option value for key
    public func option(key: String) -> String? {
        if let optarg = self.options[key] {
            return optarg.value
        }
        return nil
    }
}
