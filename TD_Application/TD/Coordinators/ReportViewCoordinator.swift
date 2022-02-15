//
//  ReportViewCoordinator.swift
//  TD
//
//  Created by Sharon Wolfovich on 10/03/2021.
//

import Foundation
import MapKit
import CoreData

final class ReportViewCoordinator: NSObject, MKMapViewDelegate {
    
    var map: MKMapView
    var initialized = false
    var tapGestureRecognizer: UIGestureRecognizer!
    var userLocation: MKUserLocation!
    var timeStamp: Date!
    var coordStamp: CLLocationCoordinate2D!
    
    init(map: MKMapView) {
        self.map = map
        self.map.showsUserLocation = false
        super.init()
    }

    private func centerMapArroundAnnotations(mapView: MKMapView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let center = CLLocationCoordinate2D(latitude: 37.786_996, longitude: -122.440_100)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if (!initialized){
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0050, longitudeDelta: 0.0050))
            
            mapView.setRegion(region, animated: false)
            mapView.register(CarAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(FootAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(UncertainAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            initialized = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            // Geo Fence
            let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purple
            circleRenderer.fillColor = UIColor.purple
            circleRenderer.alpha = 0.1
            
            return circleRenderer
            //} else if overlay is MKPolyline{
        } else{
            // Direction line
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = UIColor.blue
            render.lineWidth = 4.0
            return render
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view: MKMarkerAnnotationView!
        
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let annotation = annotation as? DetectedAnnotationWrapper else { return nil }
        switch annotation.detectPointAnnotation.type {
        
        case .car:
            view = CarAnnotationView(annotation: annotation.detectPointAnnotation, reuseIdentifier: CarAnnotationView.ReuseID)
        case .foot:
            view = FootAnnotationView(annotation: annotation.detectPointAnnotation, reuseIdentifier: FootAnnotationView.ReuseID)
        case .uncertain:
            view = UncertainAnnotationView(annotation: annotation.detectPointAnnotation, reuseIdentifier: UncertainAnnotationView.ReuseID)
        }
        
        view.animatesWhenAdded = true
        view.canShowCallout = true
        view.markerTintColor = UIColor.purple
        let imageView = UIImageView(image: annotation.image)
        imageView.contentMode = .scaleAspectFit
        view.detailCalloutAccessoryView = imageView
        
        return view
    }
    
    // Handle Tap on Map
    @objc func notifyUpdate(gesture: UIGestureRecognizer) {
        
        if gesture.state == .ended {
            print ("Gesture....")
            
            // Do what needed
        }
    }
    
    func addAnnotations(detectedObject: DetectedObject){
        for locationData in detectedObject.locationArray {
            let location = CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)
            let annotation = DetectedAnnotation(location: location)
            annotation.uuid = UUID()
            
            let formatter3 = DateFormatter()
            formatter3.dateFormat = "HH:mm E, d MMM y"
            self.timeStamp = locationData.timeStamp

            annotation.title = formatter3.string(from: locationData.timeStamp!)
            annotation.subtitle = detectedObject.licenseNumber
            annotation.type = detectedObject.dType
            
            
            let detectedAnnotationWrapper = DetectedAnnotationWrapper(detectPointAnnotation: annotation)
            detectedAnnotationWrapper.image = UIImage(data: locationData.image!)
            
            self.map.addAnnotation(detectedAnnotationWrapper)
        }
        
        
        map.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        map.showAnnotations(map.annotations, animated: true)
    }
}
