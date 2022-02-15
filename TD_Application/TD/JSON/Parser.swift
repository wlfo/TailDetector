//
//  Parser.swift
//  TD
//
//  Created by Sharon Wolfovich on 16/05/2021.
//

import Foundation
import os

class Parser {
    static let myLog = OSLog(subsystem: "proudhon.td", category: "testing")
    
    struct Command: Codable {
        var command: String
        var response: String
    }
    
    fileprivate static func prepareString(_ jsonstr: inout String) {
        jsonstr = jsonstr.replacingOccurrences(of: "False", with: "false")
        jsonstr = jsonstr.replacingOccurrences(of: "True", with: "true")
        jsonstr = jsonstr.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func parseCommandResponse(jsonString: String) -> Command {
        var response: Command?
        
        var jsonstr = jsonString
        prepareString(&jsonstr)
        
        do {
            let jsonData = Data(jsonstr.utf8)
            let decoder = JSONDecoder()
            response = try decoder.decode(Command.self, from: jsonData)
        } catch {
            print("Error while decoding string: \(jsonString)")
            os_log("Error while decoding a string", log: myLog, type:.error)
            
            response = nil
        }
        
        return response!
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
            response = try decoder.decode(T.self, from: jsonData)
        } catch {
            print("Error while decoding string: \(jsonString)")
            os_log("Error while decoding a string", log: myLog, type:.error)
            
            response = nil
        }
        
        return response!
    }
    
}

