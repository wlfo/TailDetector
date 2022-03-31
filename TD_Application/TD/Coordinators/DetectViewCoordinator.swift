//
//  DetectViewCoordinator.swift
//  TD
//
//  Created by Sharon Wolfovich on 13/02/2021.
//
import Foundation
import SwiftUI
import MapKit
import UIKit
import CoreData

final class DetectViewCoordinator: NSObject, MKMapViewDelegate, AnnotationDataDelegate, DetectViewUpdater, CLLocationManagerDelegate {
    
    //var instruction: String = ""
    var instruction: Instruction?
    var map: MKMapView
    var initialized = false
    var dpList: LinkedList<DetectionZoneAnnotation>
    var dpList4Instructions: LinkedList<DetectionZoneAnnotation>
    var tapGestureRecognizer: UIGestureRecognizer!
    var packetProcessor: PacketProcessor!
    var userLocation: MKUserLocation!
    var initialUserLocation: CLLocation!
    var decenter = false // true means not at the center
    var trackingMode: MKUserTrackingMode = .none
    //let userTrackingButton: MKUserTrackingButton!
    
    var timeStamp: Date!
    var coordStamp: CLLocationCoordinate2D!
    private var scheduleCheck: RepeatingTimer?
    
    // FAC
    //var speed: CLLocationSpeed?
    var factor: Double = 3.0
    //let fctr: Factor!
    static let SLOW = 5.0
    static let MEDIUM = 20.0
    static let FAST = 30.0
    //var regionFactor: Double = 1.0//DetectViewCoordinator.SLOW
    var oldRegionFactor: Double = 3.0
    
    
    init(map: MKMapView) {
        // FAC
        //self.fctr = Factor()
        //self.factor = 1.0
        
        self.map = map
        self.dpList = LinkedList<DetectionZoneAnnotation>()
        self.dpList4Instructions = LinkedList<DetectionZoneAnnotation>()
        //self.userTrackingButton = MKUserTrackingButton(mapView: map)
        //self._showAlert = showingAlert
        //self._alertMessage = alertMessage
        super.init()
        self.packetProcessor = PacketProcessor(dropDelegate: self)
        PTCommandInterface.shared.setPacketProcessor(pp: packetProcessor)
        PTVehicleInterface.shared.setPacketProcessor(pp: packetProcessor)
        self.instruction = Instruction()
    }
    
    // FAC
    /*func getFactor() -> Factor {
        return self.fctr
    }*/
    
    
    class Instruction: ObservableObject {
        @Published var instruction = ""
        
        func setInstruction(instruction: String){
            self.objectWillChange.send()
            self.instruction = instruction
        }
    }
    
    // Create timer that will calculate instruction every timeInterval
    func startTimedLocationTracking(start: Bool){
        
        if !start {
            if self.scheduleCheck != nil {
                self.scheduleCheck?.suspend()
                self.scheduleCheck = nil
            }
        } else {
            // Schedule Checking Jetson components status
            self.scheduleCheck = RepeatingTimer(timeInterval: 2)
            self.scheduleCheck!.eventHandler = {
                print("startTimedLocationTracking Fired")
                self.calculateInstruction()
            }
            
            self.scheduleCheck!.resume()
        }
    }
    
    // Calculate Driving instruction to the next detection zone
    private func calculateInstruction(){
        
        // If already reached the next detection zone, remove it from list
        if !removeDetectionZoneIfThere(){
            // End of mission
            
            DispatchQueue.main.async {
                self.instruction?.setInstruction(instruction: "You Reached the Last Detection Zone")
            }
            return
        }
        
        // Calculate instructions from my location to the next detection zone
        let userLocation = getUserLocation()
        
        // Origin
        let placeOrigin = MKPlacemark(coordinate: userLocation.coordinate)
        let origin = MKMapItem(placemark: placeOrigin)
        
        // Todo: Find mechanism to figure out the next detection zone
        // Destination
        let placeDestination = MKPlacemark(coordinate: (dpList4Instructions.first?.value.coordinate)!) // Temporarily
        let destination = MKMapItem(placemark: placeDestination)
        let request = MKDirections.Request()
        request.source = origin
        request.destination = destination
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { (results, error) in
            if let routes = results?.routes {
                let route = routes.first!
                let steps = route.steps
                var instruction = ""
                
                for step in steps {
                    print("In Total STEP: \(step.instructions)")
                }
                
                for step in steps {
                    instruction = step.instructions
                    if !instruction.isEmpty {
                        break
                    }
                }
                
                DispatchQueue.main.async {
                    self.instruction?.setInstruction(instruction: instruction)
                }
                    print("STEP IS: \(self.instruction?.instruction ?? "")")
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        guard let annotation = view.annotation as? DetectedAnnotation else {
            return
        }
        
        let uuid = annotation.uuid
        
        switch annotation.type {
        case .car:
            print(annotation.title as Any)
            self.packetProcessor.setPacketForPreview(uuid: uuid, type: annotation.type)
        case .foot:
            print(annotation.title as Any)
        case .uncertain:
            print(annotation.title as Any)
            self.packetProcessor.setPacketForPreview(uuid: uuid, type: annotation.type)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        
        /*
        // FAC
        var distanceIntervalMeter: Double = 0
        
        if coordStamp != nil && timeStamp != nil {
            
            let timeIntervalSec = Date().timeIntervalSince(timeStamp)
            print("t-Interval \(String(describing: timeIntervalSec))")
            
            let distanceInterval = MapKitHelper.distance(lat1: userLocation.coordinate.latitude, lon1: userLocation.coordinate.longitude, lat2: self.coordStamp.latitude, lon2: self.coordStamp.longitude, unit: "K")
            
            distanceIntervalMeter = distanceInterval * 1000
            print("d-Interval \(distanceIntervalMeter)")
            
            if timeIntervalSec != 0 {
                setFactor(factor: distanceIntervalMeter/timeIntervalSec)
                //fctr.factor = distanceIntervalMeter/timeIntervalSec
                print("Factor: \(factor )")
            }
        }
        
        coordStamp = userLocation.coordinate
        timeStamp = Date()
        */
        
        
        // Keep user location in the center
        if !decenter && map.userTrackingMode == .none {
            map.setCenter(userLocation.coordinate, animated: true)
        }
        
        if (!initialized){
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0050, longitudeDelta: 0.0050))
            
            mapView.setRegion(region, animated: false)
            mapView.register(CarAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(FootAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(UncertainAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            initialized = true
            
            // Relevant only if regionFactor changed and in .none tracking mode
        } else if map.userTrackingMode == .none {
            
            
            /*if factor <= 12 {
                self.regionFactor = DetectViewCoordinator.SLOW
            } else if factor > 12 && factor < 25 {
                self.regionFactor = DetectViewCoordinator.MEDIUM
            } else {
                self.regionFactor = DetectViewCoordinator.FAST
            }*/
            
            // Instead of using discrete numbers I am using continuous values (speed)
            //self.regionFactor = self.factor
            
            //map.setCenter(userLocation.coordinate, animated: false)
            //self.decenter = false
            //var oldRegionFactor: Double?
            // Region Factor did not changed. No need to set region
            if abs(oldRegionFactor - self.factor) < 3 {
                return
            }
            
            self.oldRegionFactor = self.factor
            
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0005 * self.factor, longitudeDelta: 0.0005 * self.factor))
            print("Factor: F is \(self.factor)")
            
            // Arrange region only if not decentered
            if !decenter && map.userTrackingMode == .none {
                mapView.setRegion(region, animated: true)
            }
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
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is DetectionZoneAnnotation {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "DetectionZoneAnnotationView") as? DetectionZoneAnnotationView
            
            if view == nil {
                view = DetectionZoneAnnotationView(annotation: annotation, reuseIdentifier: "DetectionZoneAnnotationView")
                view?.canShowCallout = false
            }
            
            // Put index inside
            let dpAnnotation = annotation as? DetectionZoneAnnotation
            view?.glyphText = String(dpAnnotation!.index)
            view?.annotation = annotation
            view?.markerTintColor = UIColor.systemGreen
            
            // Add fence
            let fence = dpAnnotation!.fence
            map.addOverlay(fence!)
            reconstructAnnotations(dpAnnotation)
            return view
            
        }
        
        guard let annotation = annotation as? DetectedAnnotation else { return nil }
        
        switch annotation.type {
        case .car:
            return CarAnnotationView(annotation: annotation, reuseIdentifier: CarAnnotationView.ReuseID)
        case .foot:
            return FootAnnotationView(annotation: annotation, reuseIdentifier: FootAnnotationView.ReuseID)
        case .uncertain:
            return UncertainAnnotationView(annotation: annotation, reuseIdentifier: UncertainAnnotationView.ReuseID)
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool){
        
        if (!initialized){
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0050, longitudeDelta: 0.0050))
            mapView.setRegion(region, animated: false)
           
        }
        
        // To prevent Race condition
        self.trackingMode = mode
        switch mode {
        case .follow:
            break
        case .followWithHeading:
            // Not relevant
            /*let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.00005, longitudeDelta: 0.00005))
                mapView.setRegion(region, animated: true)*/
            break
        case .none:
            // If changing to .none mode using tracking mode button return to center
            self.decenter = false
            break
        default:
            break
        }
        
        
        // If asked to cancel decenter map, set flag and remove the User Tracking Button
        /*if self.decenter == true {
            self.decenter = false
            for subview in map.subviews where subview is MKUserTrackingButton {
                subview.removeFromSuperview()
            }
        }*/
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        
        // Arrange heading only if centered
        if !decenter {
            map.camera.heading = newHeading.trueHeading
            map.setCamera(map.camera, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let loc = locations.last!
        let acc = loc.horizontalAccuracy
        print(acc)
        if acc < 0 || acc > 10 {
            return // wait for the next one
        }
        let coord = loc.coordinate
        print("You are at \(coord.latitude) \(coord.longitude)")
        
        let speed = abs(loc.speed)
        print("SPEED \(speed)")
        //self.speed = speed
        // Instead of FAC
        setFactor(factor: speed.rounded(.up))
        
        //self.innerSpeedPublisher.setSpeed(speed: String(speed))
    }
    
    
    // FAC
    func setFactor(factor: Double){
        //objectWillChange.send()
        
        let _min = min(30.0, factor)
        let _max = max(_min, 3.0)
        
        let _div = (_max / 5).rounded(.down)
        let _fac = (_div + 1) * 5
        
        self.factor = _fac
    }
    
    // If decentering map add UserTrackingButton to map
    func setDecenter(){
        self.decenter = true
        /*if !map.subviews.contains(userTrackingButton){
            map.addSubview(userTrackingButton)
        }*/
    }
    
    private func createDirection(dpAnnotation: DetectionZoneAnnotation ,coordOrigin: CLLocationCoordinate2D, coordDestination: CLLocationCoordinate2D){
        
        // If already loaded no need to reconstruct denuevo
        if dpAnnotation.route != nil {
            self.map.addOverlay(dpAnnotation.route.polyline, level: .aboveRoads)
            return
        }
        
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
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { (results, error) in
            if let routes = results?.routes {
                let route = routes.first!
                dpAnnotation.route = route
                self.map.addOverlay(route.polyline, level: .aboveRoads)
            }
        })
    }
    
    // Create Annotation View and attach Annotation to it
    fileprivate func reconstructAnnotations(_ dpAnnotation: DetectionZoneAnnotation?) {
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
    
    func saveAnnotations() {
        // Do something
    }
    
    // Comparing two DetectionZoneAnnotation by UUID
    func predicate(lhs: DetectionZoneAnnotation, rhs: DetectionZoneAnnotation) -> Bool{
        return lhs.uuid == rhs.uuid
    }
    
    // Fetch all annotations (i.e AnnotationData) from previuos view 
    func loadAnnotations() {
        
        func fetchAllAnnotations(completion: @escaping (Result<[AnnotationData], Error>) -> Void) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationData")
            let sortByDateTaken = NSSortDescriptor(key: #keyPath(AnnotationData.index), ascending: true)
            fetchRequest.sortDescriptors = [sortByDateTaken]
            
            context.perform {
                do {
                    let allAnnotations = try context.fetch(fetchRequest)
                    completion(.success(allAnnotations as! [AnnotationData]))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        // Completion after fetching data completed
        // Start building the map with annotations from Edit View
        fetchAllAnnotations { [self] (annotationsResult) in
            switch annotationsResult {
            case let .success(annotations):
                if annotations.count > 0 {
                    //let dpList = LinkedList<DetectionZoneAnnotation>()
                    annotations.forEach{
                        let dp = DetectionZoneAnnotation(annotationData: $0)
                        if self.dpList.contains(pred: self.predicate, value: dp) {
                            // Do nothing
                        } else {
                            self.dpList.append(value: dp)
                            
                            // Duplicate dpList for Steps Instruction mechanism
                            self.dpList4Instructions.append(value: dp)
                        }
                        
                        print("count \(self.dpList.count)")
                    }
                    
                    var allAnnotations = [DetectionZoneAnnotation]()
                    
                    if self.dpList.count > 0 {
                        for i in 0...self.dpList.count - 1 {
                            let node = self.dpList.nodeAt(index: i)
                            let tempAnnotation = node?.value
                            
                            // Set index according to order inside list
                            tempAnnotation?.index = i + 1
                            allAnnotations.append(tempAnnotation!)
                        }
                        
                        self.map.addAnnotations(allAnnotations)
                        
                        // Show all annotations at once
                        self.map.showAnnotations(self.map.annotations, animated: true)
                    }
                    
                    // Initiate HashTables in PacketProcessor
                    packetProcessor.initiateDynamicProperties(numberOfHashTables: self.dpList.count)
                    
                }
                break
            case .failure:
                print("Failure fetching annotationd")
                break
            }
        }
    }
    
    func unloadAnnotations() {
        self.dpList.removeAll()
        self.dpList4Instructions.removeAll()
        let overlays = self.map.overlays
            self.map.removeOverlays(overlays)
            let annotations = self.map.annotations.filter {
                    $0 !== self.map.userLocation
                }
            self.map.removeAnnotations(annotations)
    }
    
    func arrange(){
        /*self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)*/
    }
    
    // Todo: Enhance this method to contain whole detection information
    fileprivate func createAnnotation(_ location: CLLocationCoordinate2D, _ uuid: UUID, _ title: String, _ type: DetectedAnnotation.DetectType) {
        let annotation = DetectedAnnotation(location: location)
        annotation.uuid = uuid
        annotation.title = title
        annotation.subtitle = "Describe ..."
        annotation.type = type
        
        self.map.addAnnotation(annotation)
    }
    
    func addAnnotationForDetected(uuid: UUID, location: CLLocationCoordinate2D, title: String, type: DetectedAnnotation.DetectType) {
        
        var dAnnotation: DetectedAnnotation?
        var mkAnnotation: MKAnnotation?
        for annotation in self.map.annotations.enumerated() {
            if let detectedAnnotation = annotation.element as? DetectedAnnotation {
                if detectedAnnotation.uuid == uuid {
                    dAnnotation = detectedAnnotation
                    mkAnnotation = annotation.element
                }
            }
        }
        
        if dAnnotation == nil {
            createAnnotation(location, uuid, title, type)
        } else {
            if dAnnotation?.type == .car || type == .uncertain { // Do nothing
                return
            } else {
                self.map.removeAnnotation(mkAnnotation!)
                createAnnotation(location, uuid, title, type)
            }
        }
    }
    
    // Check if the distance between two locations is less than the radius given
    func isInRadius(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D, radius: Double) -> Bool {
        let mkl = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let dist = mkl.distance(from: CLLocation(latitude: coord2.latitude, longitude: coord2.longitude))
        
        return dist.isLess(than: radius)
    }
    
    
    // Check if reached next detection zone
    func removeDetectionZoneIfThere() -> Bool {
        let nextDetectionZoneCoord = self.dpList4Instructions.first?.value.coordinate
        
        if nextDetectionZoneCoord == nil {
            return false
        }
        
        // Check if around User Location
        if isInRadius(coord1: nextDetectionZoneCoord!, coord2: self.userLocation.coordinate, radius: DetectionZoneAnnotation.IN_ZONE_RADIUS) {
            _ = self.dpList4Instructions.remove(node: self.dpList4Instructions.first!)
        }
        
        if self.dpList4Instructions.first == nil {
            return false
        } else {
            return true
        }
    }
    
    
    // Check if inside one of the detection zones
    // location: the current location where I detected a vehicle
    func drop(location: CLLocationCoordinate2D) -> (detectionZoneIndex: Int, drop: Bool) {
        
        // Check if around the initial User Location
        if isInRadius(coord1: location, coord2: self.initialUserLocation.coordinate, radius: DetectionZoneAnnotation.FENCE_RADIUS) {
            return (0, false)
        }
        
        if dpList.count > 0 {
            for index in 0...dpList.count - 1 {
                let detectionZone = dpList.nodeAt(index: index)!.value as DetectionZoneAnnotation
                
                // Check if distance is less than the radius of the detection zone
                if isInRadius(coord1: location, coord2: detectionZone.coordinate, radius: DetectionZoneAnnotation.FENCE_RADIUS) {
                    return (index + 1, false)
                }
            }
        }
        
        return (-1, true)
    }
    
    // Handle Tap on Map
    @objc func notifyUpdate(gesture: UIGestureRecognizer) {
        
        if gesture.state == .ended {
            print ("Gesture....")
            
            // Do what needed
        }
    }
    
    // Get Reverse Geocoding
    func lookUpCurrentLocation(coord: CLLocationCoordinate2D ,completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        let geocoder = CLGeocoder()
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                completionHandler(firstLocation)
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                completionHandler(nil)
                                            }
                                        })
    }
    
    func getUserLocation() -> MKUserLocation {
        self.userLocation = self.map.userLocation
        return self.map.userLocation
    }
    
    func setInitialUserLocation(){
        self.initialUserLocation = self.userLocation.location
    }
}

/*class Factor: ObservableObject {
    @Published var factor: Double = 0
    
    func setFactor(factor: Double){
        objectWillChange.send()
        self.factor = factor
    }
    
}*/


