//
//  MyOverlay.swift
//  TD
//
//  Created by Sharon Wolfovich on 07/02/2021.
//

import MapKit

class MyOverlay: NSObject, MKOverlay {
  let coordinate: CLLocationCoordinate2D
  let boundingMapRect: MKMapRect
  
  init(myCircleOverlay: MyCircleOverlay) {
    boundingMapRect = myCircleOverlay.boundingMapRect
    coordinate = myCircleOverlay.coordinate
  }
}
