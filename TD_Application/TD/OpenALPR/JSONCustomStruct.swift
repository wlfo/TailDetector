//
//  JSONCustomStruct.swift
//  TD
//
//  Created by Sharon Wolfovich on 29/06/2021.
//

import Foundation
class JSONCustomStruct {
    
    // Represents vehicle recognition data produced by openalpr
    struct Response: Codable {
        var plate: String
        var plate_crop_jpeg: String
        var best_plate_number: String
        var country: String
        var camera_id: Int32
        var gps_latitude: Int
        var gps_longitude: Int
        var make: String
        var color: String
        var make_model: String
        var year: String
        var vehicle_crop_jpeg: String
    }
}
