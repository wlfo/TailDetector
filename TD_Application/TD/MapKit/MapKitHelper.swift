//
//  Helper.swift
//  TD
//
//  Created by Sharon Wolfovich on 18/02/2021.
//

import Foundation

class MapKitHelper {
    
    // This function converts decimal degrees to radians
    static func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }

    
    // This function converts radians to decimal degrees
    static func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }

    static func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
}
