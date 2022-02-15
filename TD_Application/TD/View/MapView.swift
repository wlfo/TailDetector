//
//  MapView.swift
//  TD
//
//  Created by Sharon Wolfovich on 24/01/2021.
//

import SwiftUI
import MapKit
import Combine


struct MapView: UIViewRepresentable {

    var map = MKMapView()
    let locationManager = CLLocationManager()
    let mpCoordinator: MKMapViewDelegate!
    
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator

        map.showsUserLocation = true
        map.userTrackingMode = .followWithHeading
        map.mapType = .standard
        map.isRotateEnabled = true 
        map.showsCompass = true
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
    
    func changeMapType(mapType: MKMapType){
        self.map.mapType = mapType
    }
        
    func loadAnnotations(){
        let coordinator = map.delegate as! AnnotationDataDelegate
        coordinator.loadAnnotations()
    }
    
    func unloadAnnotations(){
        let coordinator = map.delegate as! AnnotationDataDelegate
        coordinator.unloadAnnotations()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //uiView.mapType = self.mapType
        
    }
    
}


extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
            }, completion: nil)
    }
}

