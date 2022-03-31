//
//  Dropable.swift
//  TD
//
//  Created by Sharon Wolfovich on 18/02/2021.
//

import Foundation
import MapKit

// Todo: Move outside
protocol DetectViewUpdater {
    
    // Decide if packet should be dropped according to location.
    // If not dropped update view with license plate preview
    func drop(location: CLLocationCoordinate2D) -> (detectionZoneIndex: Int, drop: Bool)
    
    // Add Annotation to MapView with whole detection information
    func addAnnotationForDetected(uuid: UUID, location: CLLocationCoordinate2D, title: String, type: DetectedAnnotation.DetectType)
    
    func lookUpCurrentLocation(coord: CLLocationCoordinate2D ,completionHandler: @escaping (CLPlacemark?)
                                -> Void )
    
    func getUserLocation() -> MKUserLocation
}
