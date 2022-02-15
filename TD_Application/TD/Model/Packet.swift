//
//  Packet.swift
//  TD
//
//  Created by Sharon Wolfovich on 18/02/2021.
//

import Foundation
import SwiftUI


class Packet: ObservableObject, Identifiable {
    var id = UUID()
    var plateImage: UIImage!
    var licensePlateNumber: String!
    var timeStamp: Date!
    var fullImage: UIImage!
    var model: String!
    var color: String!
    var year: String!
    var latitude: Double!
    var longitude: Double!
    var drop: Bool = false
    var detectPointIndex: Int = -1
    var city: String!
    var country: String!
    var street: String!
    var alreadyDetected = false
    var make: String!
    var cameraId: Int32!
    var isProcessed = false
}
