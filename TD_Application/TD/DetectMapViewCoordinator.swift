//
//  DetectMapViewCoordinator.swift
//  TD
//
//  Created by Sharon Wolfovich on 12/02/2021.
//


import Foundation
import SwiftUI
import MapKit
import UIKit

class DetectMapViewCoordinator: NSObject, MKMapViewDelegate {
    
    
    @Environment(\.managedObjectContext) var context
    //@Binding var showAlert: Bool
    //@Binding var alertMessage: AlertMessage
    var map: MKMapView
    var initialized = false
    var dpList: LinkedList<DetectPointAnnotation>
    
    init(map: MKMapView) {
        self.map = map
        self.dpList = LinkedList<DetectPointAnnotation>()
        //self._showAlert = showingAlert
        //self._alertMessage = alertMessage
        super.init()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "DetectPointAnnotationView") as? CustomMKMarkerAnnotationView
        
        if view == nil {
            view = CustomMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "DetectPointAnnotationView")
            view?.canShowCallout = false
        }
        
        // Put index inside
        let dpAnnotation = annotation as? DetectPointAnnotation
        view?.glyphText = String(dpAnnotation!.index)
        view?.annotation = annotation
        view?.markerTintColor = UIColor.systemGreen
        
        // Add fence
        let fence = dpAnnotation!.fence
        map.addOverlay(fence!)
        
        
        
        print ("return view")
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        
        if (!initialized){
            mapView.setRegion(region, animated: false)
            
        }
        
        initialized = true
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
        } /*else {
         let myCircleOverlay = overlay as! MyCircleOverlay
         /*let renderer = MKCircleRenderer(circle: myCircleOverlay.mkCircleOverlay)
         renderer.lineWidth = 3.0
         renderer.strokeColor = UIColor.red
         renderer.fillColor = UIColor.yellow
         renderer.alpha = 0.8*/
         
         let renderer = MyOverlayRendererView(overlay: myCircleOverlay, overlayImage: UIImage(named: "Replace2")!)
         
         return renderer
         }*/
    }
}
    
