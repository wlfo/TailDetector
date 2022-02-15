//
//  DataResetHelper.swift
//  TD
//
//  Created by Sharon Wolfovich on 30/05/2021.
//

import Foundation
import SwiftUI

class DataResetHelper: NSObject, ObservableObject {
    static var UPDATE_DATA = "Update Data"
    static var shared = DataResetHelper()
    let publisher = NotificationCenter.Publisher(center: .default, name: Notification.Name(DataResetHelper.UPDATE_DATA)) .receive(on: RunLoop.main)
    private override init(){}
    
    func reset(){
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name(DataResetHelper.UPDATE_DATA), object: true, userInfo: nil)
        center.post(notification)
    }
}
