//
//  MyCircleOverlay.swift
//  TD
//
//  Created by Sharon Wolfovich on 07/02/2021.
//

import MapKit

class MyCircleOverlay: NSObject, MKOverlay {
    let mkCircleOverlay: MKCircle
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    
    init(center coord: CLLocationCoordinate2D, radius: CLLocationDistance)
    {
        mkCircleOverlay = MKCircle(center: coord, radius: radius)
        boundingMapRect = mkCircleOverlay.boundingMapRect
        coordinate = coord
    }
}
