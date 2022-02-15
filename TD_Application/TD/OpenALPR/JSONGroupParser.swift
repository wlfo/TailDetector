//
//  JSONGroupParser.swift
//  TD
//
//  Created by Sharon Wolfovich on 03/05/2021.
//

import Foundation
import os

class JSONGroupParser {
    static let myLog = OSLog(subsystem: "proudhon.td", category: "testing")
    
    struct Command: Codable {
        var command: String
        var response: String
    }
    
    static func parse<T:Codable>(jsonString: String, type: T.Type) -> Codable {
        var response: T?
        
        var jsonstr = jsonString
        jsonstr = jsonstr.replacingOccurrences(of: "'", with: "\"")
        jsonstr = jsonstr.replacingOccurrences(of: "False", with: "false")
        jsonstr = jsonstr.replacingOccurrences(of: "True", with: "true")
        jsonstr = jsonstr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let jsonData = Data(jsonstr.utf8)
            let decoder = JSONDecoder()
            response = try? decoder.decode(T.self, from: jsonData)
            if (response != nil){
                NSLog("SuccessParsing")
                os_log("SuccessParsing", log: myLog, type:.debug)
            } else {
                os_log("FailedParsing", log: myLog, type:.debug)
            }
        }
        
        return response
    }
    
}
