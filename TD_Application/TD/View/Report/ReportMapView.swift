//
//  ReportMapView.swift
//  TD
//
//  Created by Sharon Wolfovich on 10/03/2021.
//

import Foundation
import MapKit
import SwiftUI

struct ReportMapView: UIViewRepresentable {

    var map = MKMapView()
    let mpCoordinator: MKMapViewDelegate!
    let locationManager = CLLocationManager()
    
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        map.showsUserLocation = false
        map.mapType = .standard
        map.isRotateEnabled = true
        map.showsTraffic = true
        map.showsBuildings = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        return map
    }
    
    func makeCoordinator() -> MKMapViewDelegate {
        return mpCoordinator
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
    }    
}
