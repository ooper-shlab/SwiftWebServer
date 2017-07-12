//
//  Director.swift
//  SwiftWebServer
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/5/3.
//  Copyright (c) 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

protocol Director {
    init(request: HTTPRequest, response: HTTPResponse)
    
    func direct()
}

class ChiefDirector: Director {
    var request: HTTPRequest
    var response: HTTPResponse
    class func findDirector(_ request: HTTPRequest, _ response: HTTPResponse) -> Director {
        return ChiefDirector(request: request, response: response)
    }
    
    required init(request: HTTPRequest, response: HTTPResponse) {
        self.request = request
        self.response = response
    }

    private func send(_ message: String) {
        response.transmitter.send(message)
    }
    func direct() {
        let host = request.headers["host"]
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = host
        urlComponents.path = request.path!
        let url = urlComponents.url
        print("url=\(url?.absoluteString ?? "nil")")
        var documentURL = Options.instance.staticBaseURL.appendingPathComponent(request.path!)
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: documentURL.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                for file in Options.instance.defaults {
                    let fileURL = documentURL.appendingPathComponent(file)
                    if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) && !isDirectory.boolValue {
                        documentURL = fileURL
                        break
                    }
                }
            }
            print("documentURL=\(documentURL)")
            do {
                let fileData = try Data(contentsOf: documentURL)
                let ext = documentURL.pathExtension
                if let type = Options.instance.types[ext] {
                    response.contentType = type
                } else {
                    response.contentType = "application/octet-stream"
                }
                response.contentLength = fileData.count
                response.sendHeaders()
                response.transmitter.send(fileData)
                response.transmitter.close()
                return
            } catch let error {
                print(error)
            }
        }
        //
        NSLog("sending response")
        response.contentType = "text/html"
        response.status = HTTPStatus.notFound
        response.sendHeaders()
        send("<h1>\(response.status.fullDescription)</h1>\r\n")
        send("The requested resource \(request.path!) was not found on this server.<br>\r\n")
        response.transmitter.close()
        
    }
}
