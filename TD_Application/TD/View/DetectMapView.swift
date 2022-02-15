//
//  DetectMapView.swift
//  TD
//
//  Created by Sharon Wolfovich on 22/07/2021.
//
import SwiftUI
import MapKit
import Combine


struct DetectMapView: UIViewRepresentable {
    
    var map: MKMapView!
    let locationManager = CLLocationManager()
    let mpCoordinator: MKMapViewDelegate!
    
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        
        map.showsUserLocation = true
        map.userTrackingMode = .none
        map.mapType = .standard
        map.isRotateEnabled = true
        map.showsCompass = true
        map.showsTraffic = true
        map.showsBuildings = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        //map.showsScale = true
        //map.showsLargeContentViewer = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.delegate = mpCoordinator as? CLLocationManagerDelegate
        
        let region = MKCoordinateRegion(center: map.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        
        map.setRegion(region, animated: true)
        
        return map
    }
    
    func makeCoordinator() -> MKMapViewDelegate {
        return mpCoordinator
    }
    
    func changeMapType(mapType: MKMapType){
        self.map.mapType = mapType
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    func loadAnnotations(){
        let coordinator = map.delegate as! AnnotationDataDelegate
        coordinator.loadAnnotations()
    }
    
    func unloadAnnotations(){
        let coordinator = map.delegate as! AnnotationDataDelegate
        coordinator.unloadAnnotations()
    }
}

