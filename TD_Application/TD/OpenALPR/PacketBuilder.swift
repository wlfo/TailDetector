//
//  PacketBuilder.swift
//  TD
//
//  Created by Sharon Wolfovich on 04/05/2021.
//

import Foundation
import SwiftUI
import UIKit

class PacketBuilder {
    
    // Build Packet object from Jetson vehicle recognition response
    static func buildPacket(group: JSONCustomStruct.Response) -> Packet{
        let packet = Packet()
        packet.plateImage = getUIImage(imageBase64String: group.plate_crop_jpeg)
        packet.licensePlateNumber = group.best_plate_number
        packet.model = group.make_model
        packet.year = group.year
        packet.fullImage = getUIImage(imageBase64String: group.vehicle_crop_jpeg)
        packet.timeStamp = Date()
        packet.latitude = Double(group.gps_latitude)
        packet.longitude = Double(group.gps_longitude)
        packet.color = group.color
        packet.make = group.make
        packet.cameraId = group.camera_id
        
        NSLog("plate number: %@ model: %@ year: %@ color: %@", packet.licensePlateNumber, packet.model, packet.year, packet.color)
        
        return packet
    }
    
    private static func getUIImage(imageBase64String: String)->UIImage {
        let newImageData = Data(base64Encoded: imageBase64String)
        let plateImage = UIImage(data: newImageData!)
    
        return plateImage!
    }
}
