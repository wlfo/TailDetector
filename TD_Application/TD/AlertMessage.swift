//
//  AlertMessage.swift
//  TD
//
//  Created by Sharon Wolfovich on 29/01/2021.
//

import Foundation

struct AlertMessage {
    var title: String = ""
    var message: String = ""
    
    init(title: String, message: String){
        self.title = title
        self.message = message
    }
}
