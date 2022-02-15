//
//  Insights.swift
//  TD
//
//  Created by Sharon Wolfovich on 18/02/2021.
//

import Foundation
import MapKit

protocol Dropable {
    func drop(location: CLLocation) -> Bool
}

class DetectPointsInsights: Dropable {
    
    
    
    func drop(location: CLLocation) -> Bool {
        return true
    }
    
    
}
