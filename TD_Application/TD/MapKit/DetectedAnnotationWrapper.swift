//
//  DetectedAnnotationWrapper.swift
//  TD
//
//  Created by Sharon Wolfovich on 10/03/2021.
//

import Foundation
import MapKit

class DetectedAnnotationWrapper: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let detectionZoneAnnotation: DetectedAnnotation!
    var image: UIImage!
    var title: String?
    var subtitle: String?
    
    init(detectionZoneAnnotation: DetectedAnnotation){
        self.detectionZoneAnnotation = detectionZoneAnnotation
        self.coordinate = detectionZoneAnnotation.coordinate
        self.title = detectionZoneAnnotation.title
        self.subtitle = detectionZoneAnnotation.subtitle
    }
}
