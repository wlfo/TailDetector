//
//  Cameras.swift
//  TD
//
//  Created by Sharon Wolfovich on 16/05/2021.
//

import Foundation

class Entities {
    
    struct Cameras: Codable {
        var cameras: [String]
    }
    
    struct ALPRDaemonUP: Codable {
        var is_up: Bool
    }
}
