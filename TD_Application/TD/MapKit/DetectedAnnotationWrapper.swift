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
    let detectPointAnnotation: DetectedAnnotation!
    var image: UIImage!
    var title: String?
    var subtitle: String?
    
    init(detectPointAnnotation: DetectedAnnotation){
        self.detectPointAnnotation = detectPointAnnotation
        self.coordinate = detectPointAnnotation.coordinate
        self.title = detectPointAnnotation.title
        self.subtitle = detectPointAnnotation.subtitle
    }
}
