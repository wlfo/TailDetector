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
    let detectZoneAnnotation: DetectedAnnotation!
    var image: UIImage!
    var title: String?
    var subtitle: String?
    
    init(detectZoneAnnotation: DetectedAnnotation){
        self.detectZoneAnnotation = detectZoneAnnotation
        self.coordinate = detectZoneAnnotation.coordinate
        self.title = detectZoneAnnotation.title
        self.subtitle = detectZoneAnnotation.subtitle
    }
}
