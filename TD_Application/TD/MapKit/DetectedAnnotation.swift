//
//  DetectedAnnotation.swift
//  TD
//
//  Created by Sharon Wolfovich on 23/02/2021.
//

import Foundation
import MapKit

class DetectedAnnotation : NSObject, Decodable, MKAnnotation {
    //dynamic var coordinate : CLLocationCoordinate2D
    var uuid = UUID()
    var title: String?
    var subtitle: String?
    
    enum DetectType: Int, Decodable {
        case car
        case foot
        case uncertain
    }
    
    var type: DetectType = .car

    init(location coord: CLLocationCoordinate2D) {
        self.latitude = coord.latitude
        self.longitude = coord.longitude
        super.init()
    }
    
    private var latitude: CLLocationDegrees = 0
    private var longitude: CLLocationDegrees = 0
    
    @objc dynamic var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}
