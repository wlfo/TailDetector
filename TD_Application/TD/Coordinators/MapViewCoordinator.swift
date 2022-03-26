//
//  MapViewCoordinator.swift
//  TD
//
//  Created by Sharon Wolfovich on 24/01/2021.
//

import Foundation
import SwiftUI
import MapKit
import UIKit
import Combine
import CoreData

class MapViewCoordinator: NSObject, MKMapViewDelegate, ReplaceRemoveDelegate, AnnotationDataDelegate, ObservableObject {
    
    //@EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) var context
    //@Binding var showAlert: Bool
    //@Binding var alertMessage: AlertMessage
    var map: MKMapView
    var initialized = false
    var decenter = false
    var dpList: LinkedList<DetectZoneAnnotation>
    var tapGestureRecognizer: UIGestureRecognizer!
    let userTrackingButton: MKUserTrackingButton!
    
    init(map: MKMapView) {
        self.map = map
        self.dpList = LinkedList<DetectZoneAnnotation>()
        self.userTrackingButton = MKUserTrackingButton(mapView: map)
        //self._showAlert = showingAlert
        //self._alertMessage = alertMessage
        super.init()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        var callout = view.subviews.filter({ (subview) -> Bool in
            subview is CustomCalloutView
        }).first
        
        callout?.removeFromSuperview()
        callout = nil
        view.constraints.forEach{
            view.removeConstraint($0)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check if no more in Edit State - To prevent adding more detect zones after already detection started
        let appState = Atomic<AppState>(AppState.shared)
        if appState.value.state != AppState.State.edit {
            return nil
        }
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "DetectZoneAnnotationView") as? CustomMKMarkerAnnotationView
        
        if view == nil {
            view = CustomMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "DetectZoneAnnotationView")
            view?.canShowCallout = false
        }
        
        // Put index inside
        let dpAnnotation = annotation as? DetectZoneAnnotation
        view?.glyphText = String(dpAnnotation!.index)
        view?.annotation = annotation
        view?.markerTintColor = UIColor.systemGreen
        
        // Add fence
        let fence = dpAnnotation!.fence
        map.addOverlay(fence!)
        
        switch dpAnnotation?.state {
        case .edit(value: .newAtEdge):
            reconstructAnnotations(dpAnnotation)
            break
            
        case .edit(value: .remove):
            reconstructAnnotations(dpAnnotation)
            
            // Now Release the remove state from this annotation
            dpAnnotation?.state = .edit(value: .newAtEdge)
            break
        case .edit(value: .update):
            reconstructAnnotations(dpAnnotation)
            dpAnnotation?.state = .edit(value: .newAtEdge)
            break
            
        default:
            break
        }
        
        print ("return view")
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        // Keep user location in the center
        if !decenter && map.userTrackingMode == .none {
            map.setCenter(userLocation.coordinate, animated: false)
            //self.decenter = false
        }
        
        if (!initialized){
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            
            mapView.setRegion(region, animated: false)
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        switch AppState.shared.state {
        case .edit:
            // Remove Gesture to prevent tap bubbling to outer view
            mapView.removeGestureRecognizer(self.tapGestureRecognizer)
            
            getAltEditCallout(view)
            
            print("in callout edit")
            break
        case .detect:
            print("in callout detect")
            break
        case .report:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool){
        if (!initialized){
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            mapView.setRegion(region, animated: false)
           
        }
        
        
        // If asked to cancel decenter map, set flag and remove the User Tracking Button
        /*if self.decenter == true {
            self.decenter = false
            for subview in map.subviews where subview is MKUserTrackingButton {
                subview.removeFromSuperview()
            }
        }*/
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("mapViewDidStopLocatingUser")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("mapViewWillStartLocatingUser")
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        //print("mapViewDidChangeVisibleRegion")
    }
    
    // Tap inside Callout
    @objc func callPhoneNumber()
    {
        print("Button tapped!")
    }
    
    // If decentering map add UserTrackingButton to map
    func setDecenter(){
        self.decenter = true
        if !map.subviews.contains(userTrackingButton){
            map.addSubview(userTrackingButton)
        }
    }
    
    // Handle Tap on Map
    @objc func notifyUpdate(gesture: UIGestureRecognizer) {
        
        if gesture.state == .ended {
            print ("Gesture....")
            
            // Alert If in state of Update Route
            map.annotations.forEach {
                let annotation = $0 as? DetectZoneAnnotation
                if annotation?.state == DetectZoneAnnotation.State.edit(value: .update) {
                    annotation?.state = .edit(value: .newAtEdge)
                    //self.alertMessage = AlertMessage(title: "Update Detect Zone", message: "Exit Update Mode.")
                    //self.showAlert = true
                }
            }
        }
    }
    
    // Add annotation by gesture
    @objc func addAnnotation(gesture: UIGestureRecognizer) {
        // Check if no more in Edit State
        let appState = Atomic<AppState>(AppState.shared)
        if appState.value.state != AppState.State.edit {
            return
        }
        
        
        if gesture.state == .ended {
            if let mapView = gesture.view as? MKMapView {
                let zone = gesture.location(in: mapView)
                let coordinate = mapView.convert(zone, toCoordinateFrom: mapView)
                var dpAnnotation: DetectZoneAnnotation!
                
                // 1. Locate DetectZoneAnnotation marked with update
                var annotationMarkedUpdate: DetectZoneAnnotation!
                map.annotations.forEach {
                    let annotation = $0 as? DetectZoneAnnotation
                    if annotation?.state == .edit(value: .update) {
                        annotationMarkedUpdate = annotation!
                    }
                }
                
                let index = dpList.count + 1
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                let context = appDelegate.persistentContainer.viewContext
                //var annotationData = AnnotationData(context: context, coordinate: coordinate, title: "Detect Zone", index: Int32(index))
                
                let annotationData = AnnotationData(context: context, longitude: coordinate.longitude, latitude: coordinate.latitude, title: "Detect Zone", index: Int32(index))
                
                print("annotationData.title = " + annotationData.title!)
                
                dpAnnotation = DetectZoneAnnotation(annotationData: annotationData)
                
                print("dpAnnotation.title = " + dpAnnotation.title!)
                
                // There is an annotation for update
                if annotationMarkedUpdate != nil {
                    dpAnnotation.index = annotationMarkedUpdate.index
                    
                    var nodeIdx: Int!
                    for i in 0...dpList.count - 1 {
                        let node = dpList.nodeAt(index: i)
                        let tempAnnotation = node?.value
                        if tempAnnotation == annotationMarkedUpdate {
                            nodeIdx = i
                        }
                    }
                    
                    // Delete annotation from context
                    DataManager.shared.delete(annotationData: annotationMarkedUpdate.annotationData)
                    
                    // Swap and copy properties from old to new
                    dpList.remove(at: nodeIdx) // Change#
                    if dpList.nodeAt(index: nodeIdx) == nil {
                        dpList.append(value: dpAnnotation)
                    } else {
                        dpList.insert(node: Node(value: dpAnnotation), at: nodeIdx)
                    }
                    
                    handleAnnotation(annotationToHandle: dpAnnotation, handleList: swapInList)
                    
                    //Now remove old annotation
                    map.removeOverlay(annotationMarkedUpdate.fence)
                    map.removeAnnotation(annotationMarkedUpdate)
                    
                } else {
                    dpList.append(value: dpAnnotation)
                    mapView.addAnnotation(dpAnnotation)
                }
            }
        }
    }
    
    private func createDirection(dpAnnotation: DetectZoneAnnotation ,coordOrigin: CLLocationCoordinate2D, coordDestination: CLLocationCoordinate2D){
        
        // Origin
        let placeOrigin = MKPlacemark(coordinate: coordOrigin)
        let origin = MKMapItem(placemark: placeOrigin)
        
        // Destination
        let placeDestination = MKPlacemark(coordinate: coordDestination)
        let destination = MKMapItem(placemark: placeDestination)
        
        let request = MKDirections.Request()
        request.source = origin
        request.destination = destination
        request.transportType = .automobile
        request.requestsAlternateRoutes = false//true//false
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { (results, error) in
            if let routes = results?.routes {
                let route = routes.first!
                dpAnnotation.route = route
                self.map.addOverlay(route.polyline, level: .aboveRoads)
            }
        })
        
        
        // For multi routes
        /*
         let directions = MKDirections(request: request)
         
         directions.calculate { [unowned self] response, error in
         guard let unwrappedResponse = response else { return }
         
         for route in unwrappedResponse.routes {
         self.map.addOverlay(route.polyline)
         //self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
         self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
         }
         }*/
    }
    
    private func removeFromList(index: Int){
        
        // Remove from context
        let node = dpList.nodeAt(index: index)
        let annotation = node!.value as DetectZoneAnnotation
        DataManager.shared.delete(annotationData: annotation.annotationData)
        
        
        // 4. Remove Annotation from list
        dpList.remove(at: index)
    }
    
    private func swapInList(index: Int){
        // 4. Remove Annotation from list
        //dpList.remove(at: index)
        
        // Do nothing ?
    }
    
    // Create Annotation View and attach Annotation to it
    fileprivate func reconstructAnnotations(_ dpAnnotation: DetectZoneAnnotation?) {
        var coordOrigin: CLLocationCoordinate2D!
        if dpList.head?.value == dpAnnotation {
            coordOrigin = map.userLocation.coordinate
        } else {
            // Not first in list. seek previous
            for i in 1...dpList.count - 1 {
                let node = dpList.nodeAt(index: i)
                let tempAnnotation = node?.value
                
                // The dp to be reconstructructed
                if tempAnnotation == dpAnnotation {
                    let prevAnnotation = node?.previous?.value
                    coordOrigin = prevAnnotation!.coordinate
                    break
                }
            }
        }
        
        let coordDestination = dpAnnotation!.coordinate
        createDirection(dpAnnotation: dpAnnotation!, coordOrigin: coordOrigin, coordDestination: coordDestination)
    }
    
    // Handle actions such as deletion and update
    fileprivate func handleAnnotation(annotationToHandle: DetectZoneAnnotation?, handleList: (Int) -> ()) {
        
        var annotationIdx: Int!
        var allAnnotations = [DetectZoneAnnotation]()
        // 2. Delete all Directions, Fences.
        // 3. Delete annotations from map
        for i in 0...dpList.count - 1 {
            let node = dpList.nodeAt(index: i)
            let tempAnnotation = node?.value
            let route = tempAnnotation?.route
            let fence = tempAnnotation?.fence
            
            if route != nil {
                let polyline = route!.polyline
                print("buttonDelete: before removeocerlay index \(i)")
                self.map.removeOverlay(polyline as MKOverlay)
                tempAnnotation?.route = nil
            }
            
            if fence != nil {
                self.map.removeOverlay(fence!)
            }
            
            if tempAnnotation == annotationToHandle {
                print("buttonDelete: annotationForDelete is index \(i)")
                annotationIdx = i
            }
            
            // Remove from map
            allAnnotations.append(tempAnnotation!)
        }
        
        print("buttonDelete: before removeAnnotations")
        map.removeAnnotations(allAnnotations)
        
        // Handle annotation according to action type (i.e remove/update)
        handleList(annotationIdx)
        
        // 5. Now add the entire annotations to map
        if dpList.count > 0 {
            allAnnotations.removeAll()
            for i in 0...dpList.count - 1 {
                let node = dpList.nodeAt(index: i)
                let tempAnnotation = node?.value
                
                // Set index according to order inside list
                tempAnnotation?.index = i + 1
                
                // Mark annotation to join the state of remove
                tempAnnotation?.state = .edit(value: .remove)
                print("buttonDelete: before append anno \(i+1)")
                allAnnotations.append(tempAnnotation!)
                print("buttonDeleteadd anno \(i+1)")
            }
            
            map.addAnnotations(allAnnotations)
        }
        
        map.overlays.forEach {
            if ($0 is MKPolyline) {
                map.removeOverlay($0)
            }
        }
    }
    
    // Build the custom Callout View
    fileprivate func getAltEditCallout(_ view: MKAnnotationView) {
        view.subviews.filter { $0 is CustomCalloutView }.forEach{
            $0.removeFromSuperview()
        }
        
        let callout = CustomCalloutView()
        
        callout.translatesAutoresizingMaskIntoConstraints = false
        callout.layer.cornerRadius = 10.0
        callout.layer.masksToBounds = true
        view.addSubview(callout)
        
        callout.widthAnchor.constraint(equalToConstant: 120).isActive = true
        callout.heightAnchor.constraint(equalToConstant: 60).isActive = true
        callout.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        callout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        callout.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Get index from DetectZone
        let dpAnnotation = view.annotation as? DetectZoneAnnotation
        let index = dpAnnotation?.index
        
        // Create Callout content
        let innerCalloutView = InnerCalloutView(delegate: self, tag: index!)
        
        let result = innerCalloutView.onDisappear(perform: {
            self.map.addGestureRecognizer(self.tapGestureRecognizer)
        })
        
        print ("on disappear \(result)")
        
        let child = UIHostingController(rootView: innerCalloutView)
        let parent = UIViewController()
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = parent.view.bounds
        
        // First, add the view of the child to the view of the parent
        parent.view.addSubview(child.view)
        // Then, add the child to the parent
        parent.addChild(child)
        callout.addSubview(parent.view)
    }
    
    func buttonUpdate(tag: Int) {
        // 1. Locate DetectZoneAnnotation for Update
        //let tag = sender.tag
        var annotationForUpdate: DetectZoneAnnotation!
        map.annotations.forEach {
            let annotation = $0 as? DetectZoneAnnotation
            if annotation?.index == tag {
                annotationForUpdate = annotation!
                annotationForUpdate.state = .edit(value: .update)
            }
        }
        
        map.selectedAnnotations.forEach({ map.deselectAnnotation($0, animated: false) })
        
        // Return tap Recofnizer
        map.gestureRecognizers?.append(tapGestureRecognizer)
        
        // Indicate that Update state
        //let overlay = MyCircleOverlay(center: annotationForUpdate.coordinate, radius: 50)
        //map.addOverlay(overlay)
    }
    
    func buttonDelete(tag: Int){
        //self.alertMessage = AlertMessage(title: "Delete Detect Zone", message: "You are about to remove current Detection Zone.")
        //self.showAlert = true
        //print("buttonDelete: start index")
        
        // Locate DetectZoneAnnotation for deleteion
        var annotationForDelete: DetectZoneAnnotation!
        map.annotations.forEach {
            let annotation = $0 as? DetectZoneAnnotation
            if annotation?.index == tag {
                annotationForDelete = annotation!
            }
        }
        
        // Handle annotation with Deletion action
        handleAnnotation(annotationToHandle: annotationForDelete, handleList: removeFromList)
        
        print("End Delete")
    }
    
    func loadAnnotations() {
        
    }
    
    func unloadAnnotations() {
        self.dpList.removeAll()
        let overlays = self.map.overlays
            self.map.removeOverlays(overlays)
            let annotations = self.map.annotations.filter {
                    $0 !== self.map.userLocation
                }
            self.map.removeAnnotations(annotations)
    }
}
