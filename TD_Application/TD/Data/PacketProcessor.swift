//
//  PacketProcessor.swift
//  TD
//
//  Created by Sharon Wolfovich on 18/02/2021.
//

import Foundation
import MapKit
import UIKit
import CoreData

class PacketProcessor: ObservableObject {
    
    @Published var plateImage: UIImage!
    @Published var cameraId: Int32!
    @Published var plateImageFrameColor: UIColor!
    @Published var revivePreview = false
    
    var detectPreviewDetails: Packet!
    var uncertainPreviewDetailsArray: [Packet] = []
    var detectPreviewDetailsArray: [Packet] = []
    var detectionsCount: Int = 0
    var dropDelegate: DetectViewUpdater!
    var hashTables = [HashTable<String, Packet>]()
    var detections = [[(Packet, Packet)]]()
    let HASHTABLE_CAPACITY = 1559
    let TIME_BETWEEN_SAME_LP_SEC = 5.0
    let DISTANCE_BETWEEN_SAME_LP_METER = 50.0
    var identifiersHashTable = HashTable<String, Packet>(capacity: 97)
    var userLocation: MKUserLocation!
    static var applyRecencyCheck = true
    
    typealias intervalMethod = (_ currentPacket: Packet, _ historyPacket: Packet, _ interval: Double) -> Bool
    
    init(dropDelegate: DetectViewUpdater) {
        self.dropDelegate = dropDelegate
        //self.detectPreviewDetailsArray = [Packet]()
    }
    
    
    // Set the starting zone - Zone Zero
    func setZoneZero(){
        self.userLocation = self.dropDelegate.getUserLocation()
    }
    
    func resetProcessor(){
        self.cameraId = nil
        self.plateImage = nil
        self.userLocation = nil
        self.revivePreview = false
        self.uncertainPreviewDetailsArray.removeAll()
        self.detections.removeAll()
        self.detectPreviewDetailsArray.removeAll()
        self.detectionsCount = 0
        self.hashTables.removeAll()
        self.detections.removeAll() 
        self.identifiersHashTable = HashTable<String, Packet>(capacity: 97)
    }
    
    // Initializa Hash Tables where detection and all identification will reside
    func initiateDynamicProperties(numberOfHashTables: Int){
        for _ in 1...numberOfHashTables+1 {
            hashTables.append(HashTable<String, Packet>(capacity: HASHTABLE_CAPACITY))
            detections.append([(Packet, Packet)]())
        }
    }
    
    // Update Observed variables of single detection preview
    func setPacketForPreview(uuid: UUID, type: DetectedAnnotation.DetectType) {
        objectWillChange.send()
        
        
        let arrayToSeek = type == .uncertain ? uncertainPreviewDetailsArray : detectPreviewDetailsArray
        for packet in arrayToSeek.enumerated() {
            if packet.element.id == uuid {
                detectPreviewDetails = packet.element
            }
        }
        
        // Make preview not hidden
        revivePreview = true
    }
    
    // Append new detected found and update Observed variable
    func appendNewDFW(packet: Packet, revive: Bool) {
        objectWillChange.send()
        detectPreviewDetailsArray.append(packet)
        detectionsCount = detectPreviewDetailsArray.count
        
        // Make preview not hidden
        revivePreview = revive
    }
    
    // Return the collection with all detections
    func getDetectedsForPreview() -> [Packet]{
        return detectPreviewDetailsArray
    }
    
    // Return the collection belongs to single detection
    func getSingleDetectedForView() -> Packet{
        return detectPreviewDetails
    }
    
    // Check if packet is outside detection zones (if outside - drop)
    // Update View with License Plate image
    // Perform detection process
    func processPacket(packet: Packet){
        
        // Get the location from the packet sent by the ALPR Service
        let location = CLLocationCoordinate2D(latitude: packet.latitude, longitude: packet.longitude)
        let result = dropDelegate.drop(location: location)
        // Check if to drop this packet according to policy (e.g not in fence or before/after drive
        if result.1 {
            packet.drop = true
            
            DispatchQueue.main.async {
                
                // Send preview to DetectView to indicate and surround with gray border
                self.cameraId = packet.cameraId
                self.plateImage = packet.plateImage
                self.plateImageFrameColor = UIColor.systemGray
            }
            
            return
        } else {
            packet.drop = false
            DispatchQueue.main.async {
                
                // Send preview to DetectView to indicate and surround with purple border
                self.cameraId = packet.cameraId
                self.plateImage = packet.plateImage
                self.plateImageFrameColor = UIColor.systemPurple
            }
            
            // Send the packet to Working Queue and forget.
            // The Object that (maybe here...) will process the packet according to Queue
            // will act as ObservableObject for DetectView too.
            packet.detectionZoneIndex = result.0
            addAndDetect(packet: packet, detectionZoneIndex: result.0)
            print("at dp index: \(result.0)")
        }
    }
    
    // Check if treat detectionZoneIndex from 0 or from 1
    func addAndDetect(packet: Packet, detectionZoneIndex: Int){
        if detectionZoneIndex < 0 {
            return
        }
        
        if PacketProcessor.applyRecencyCheck {
            
            // If recent (time) do not continue with processing
            if isRecent(packet: packet, currentHashTable: hashTables[detectionZoneIndex], interval: TIME_BETWEEN_SAME_LP_SEC, predicate: isRecentInTime){
                return
            }
            
            // If recent (distance) do not continue with processing
            if isRecent(packet: packet, currentHashTable: hashTables[detectionZoneIndex], interval: DISTANCE_BETWEEN_SAME_LP_METER, predicate: isRecentInDistance){
                return
            }
        }
        
        // If zero zone or first zone
        if detectionZoneIndex < 2 {
            addFirstDetect(packet: packet, currentHashTable: hashTables[detectionZoneIndex])
        } else {
            
            // array represents the current new license plate
            var array = [String]()
            div(array: &array, key: packet.licensePlateNumber) //Detect
            
            for index in 0...detectionZoneIndex-1 {
                // Todo: Pass this detection epiphany upward
                detect(substrings: array, currentPacket: packet, formerHashTable: hashTables[index], currentHashTable: hashTables[detectionZoneIndex])
            }
            
            // After trying to detect update all substrings inside the current HashTable
            // Remember that packet still contains the original longest substring
            for i in 0...array.count-1 {
                hashTables[detectionZoneIndex].updateValue(packet, forKey: array[i])
                //print("\(i): \(array[i])")
            }
            
        }
    }
    
    // Add all objects detected in zone Zero and zone 1
    private func addFirstDetect(packet: Packet, currentHashTable: HashTable<String, Packet>){
        var array = [String]()
        div(array: &array, key: packet.licensePlateNumber)
        
        // Remember that packet still contains the original longest substring
        for i in 0...array.count-1 {
            //hashTables[0].updateValue(packet, forKey: array[i])
            currentHashTable.updateValue(packet, forKey: array[i])
            //print("\(i): \(array[i])")
        }
    }
    
    // Use the current packet to seek same license plate from historic data inside historic HashTables
    // When finished store the current packet substrings with reference to the current packet inside current HashTable
    fileprivate func setPlacemarks(_ placemarks: CLPlacemark?, packet: Packet) {
        self.objectWillChange.send()
        if placemarks != nil {
            packet.street =  placemarks?.thoroughfare
            packet.city =  placemarks?.subLocality
            packet.country =  placemarks?.country
        }
    }
    
    /**
     Saving Packets content of detections to Core Data objects
     This is the first time we encounter this detection, so we create Detection Object
     
     - parameter currentPacket: The packet of the current detection.
     - parameter detectType: Type of detection (e.g. uncertain, car).
     - returns: Nothing
     - warning: No Warnings
     */
    fileprivate func firstSave(_ currentPacket: Packet, detectType: DetectedAnnotation.DetectType) {
        // Must use Main Thread when calling AppDelegate
        DispatchQueue.main.async(execute: {
            var context: NSManagedObjectContext!
            let app = UIApplication.shared
            let delegate = app.delegate as! AppDelegate
            context = delegate.persistentContainer.viewContext
            let dob = DetectedObject(context: context)
            dob.licenseNumber = currentPacket.licensePlateNumber
            dob.model = currentPacket.model ?? ""
            dob.year = currentPacket.year ?? ""
            dob.uuid = UUID()
            dob.dType = detectType
            
            let ld = LocationData(context: context)
            ld.latitude = currentPacket.latitude
            ld.longitude = currentPacket.longitude
            ld.timeStamp = currentPacket.timeStamp ?? Date.init(timeIntervalSince1970: 0)
            ld.ofDetectedObject = dob
            
            if let id = currentPacket.fullImage.pngData() {
                ld.image = id
            }
        })
    }
    
    /**
     Saving Packets content of detections to Core Data objects: DetectedObject and LocationData
     
     - parameter currentPacket: The packet of the current detection.
     - parameter detectType: Type of detection (e.g. uncertain, car).
     - returns: Nothing
     - warning: No Warnings
     
     # Notes: #
     1. If this is the first instance of the detected object we create DetectedObject, otherwise we
     just add new instance of LocationData to the existing DetectedObject
     */
    func saveData(_ currentPacket: Packet, detectType: DetectedAnnotation.DetectType){
        
        // Fetch Detected Objects with Completion
        func fetchAllAnnotations(completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
            
            // Using main.sync in order to synchronize access to Core Data objects
            DispatchQueue.main.sync(execute: {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DetectedObject")
                fetchRequest.predicate = NSPredicate(format: "licenseNumber == %@", currentPacket.licensePlateNumber) // ?? "")")
                
                context.perform {
                    do {
                        let detectedObjects = try context.fetch(fetchRequest)
                        completion(.success(detectedObjects as! [DetectedObject]))
                    } catch {
                        completion(.failure(error))
                    }
                }
            })
        }
        
        // Completion after fetching data completed
        // If detected object does not exist create new, else add location data
        fetchAllAnnotations { [self] (detectedObjectsResult) in
            switch detectedObjectsResult {
            case let .success(detectedObjects):
                if detectedObjects.count > 0 {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    let context = appDelegate.persistentContainer.viewContext
                    
                    if detectType == DetectedAnnotation.DetectType.car {
                        detectedObjects.first?.dType = detectType
                    }
                   
                    // Check if an instance of the same location exists
                    if let locationArray = detectedObjects.first?.locationArray {
                        for locationData in locationArray {
                            if locationData.longitude == currentPacket.longitude && locationData.latitude == currentPacket.latitude {
                                return
                            }
                        }
                    }
                    
                    // Just after confirming that this current location does nor exist I am creating LocationData
                    let ld = LocationData(context: context)
                    ld.latitude = currentPacket.latitude
                    ld.longitude = currentPacket.longitude
                    ld.timeStamp = currentPacket.timeStamp ?? Date.init(timeIntervalSince1970: 0)
                    ld.ofDetectedObject = detectedObjects.first
                    
                    if let id = currentPacket.fullImage.pngData() {
                        ld.image = id
                    }
                    
                    print("OBJ-Old \(currentPacket.licensePlateNumber ?? "")")
                    
                } else {
                    firstSave(currentPacket, detectType: detectType)
                    print("OBJ-New \(currentPacket.licensePlateNumber ?? "")")
                }
                break
            case .failure:
                print("Failure fetching annotationd")
                break
            }
        }
    }
    
    // Check if two packets with the same license number not too much close according to predicate.
    func isRecent(packet: Packet, currentHashTable: HashTable<String, Packet>, interval: Double, predicate: intervalMethod) -> Bool {
        let htEntry = currentHashTable.retrieveValue(for: packet.licensePlateNumber)
        
        // First entry in array is the longest string.
        // We strive for the longest so stop at the longest found (match)
        if htEntry!.count > 0 {
            for e in htEntry!.enumerated() {
                if packet.licensePlateNumber == e.element.licensePlateNumber {
                    
                    /*let intrvalSec = packet.timeStamp.timeIntervalSince(e.element.timeStamp)
                     if intrvalSec.isLess(than: secInterval) {
                     return true
                     }*/
                    
                    if predicate(packet, e.element, interval) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func isRecentInTime(currentPacket: Packet, historyPacket: Packet, interval: Double) -> Bool {
        let intrvalSec = currentPacket.timeStamp.timeIntervalSince(historyPacket.timeStamp)
        if intrvalSec.isLess(than: interval) {
            return true
        }
        return false
    }
    
    func isRecentInDistance(currentPacket: Packet, historyPacket: Packet, interval: Double) -> Bool {
        
        let coord1 = CLLocationCoordinate2D(latitude: currentPacket.latitude, longitude: currentPacket.longitude)
        let coord2 = CLLocationCoordinate2D(latitude: historyPacket.latitude, longitude: historyPacket.longitude)
        let mkl = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let dist = mkl.distance(from: CLLocation(latitude: coord2.latitude, longitude: coord2.longitude))
        
        if dist.isLess(than: interval) {
            return true
        }
        
        return false
        
    }
    
    // Check if the distance between two locations is less than the radius given
    func isNear(packet: Packet, currentHashTable: HashTable<String, Packet>, distInterval: Double) -> Bool {
        let htEntry = currentHashTable.retrieveValue(for: packet.licensePlateNumber)
        // coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D, distance: Double
        
        
        
        
        // First entry in array is the longest string.
        // We strive for the longest so stop at the longest found (match)
        if htEntry!.count > 0 {
            for e in htEntry!.enumerated() {
                if packet.licensePlateNumber == e.element.licensePlateNumber {
                    
                    let coord1 = CLLocationCoordinate2D(latitude: packet.latitude, longitude: packet.longitude)
                    let coord2 = CLLocationCoordinate2D(latitude: e.element.latitude, longitude: e.element.longitude)
                    let mkl = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
                    let dist = mkl.distance(from: CLLocation(latitude: coord2.latitude, longitude: coord2.longitude))
                    
                    if dist.isLess(than: distInterval) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /**
     In this function we perform detection algorithm to check if there exist an entry matched to the new packet object. When finish add the current packet to the designated Hash Table
     
     - parameter substrings: Array of substrings from the original license plate number (i.e for string length m we will get (m^2 - 3m + 2)/2)
     - parameter currentPacket: Packet of the current detection zone
     - parameter formerHashTable: Hash Table of former detection zones previous this one
     - parameter currentHashTable: Hash Table of thr current detection zone
     
     - returns: Void
     - warning: No Warning
     
     # Notes: #
     1. This function generates data for views as an observable object
     */
    func detect(substrings: [String], currentPacket: Packet, formerHashTable: HashTable<String, Packet>, currentHashTable: HashTable<String, Packet>){
        
        // array represents the current new license plate
        //var substrings = [String]()
        //div(array: &substrings, key: currentPacket.licensePlateNumber) //Detect
        
        for i in 0...substrings.count-1 {
            // Array of packets under the same key used with h(key)
            // Different license numbers are possible
            let htEntry = formerHashTable.retrieveValue(for: substrings[i])
            
            // First entry in array is the longest string.
            // We strive for the longest so stop at the longest found (match)
            if htEntry!.count > 0 {
                for e in htEntry!.enumerated() { // e.element is a Packet
                    
                    // hlp represents historic license plate
                    let hlp = e.element.licensePlateNumber ?? "No number"

                    // Check if one of the strings contains the other
                    let cont = currentPacket.licensePlateNumber.contains(hlp) || hlp.contains(currentPacket.licensePlateNumber)
                    if !cont {
                        print("almost match: \(substrings[i]) from ancestor: \(substrings[0]) is \(hlp)")
                        continue
                    }
                    
                    print("match: \(substrings[i]) from ancestor: \(substrings[0]) is \(hlp)")
                    detections[currentPacket.detectionZoneIndex].append((currentPacket, e.element))
                    identifiersHashTable.updateValue(currentPacket, forKey: currentPacket.licensePlateNumber)
                    var detectType = DetectedAnnotation.DetectType.car
                    
                    // If lp not identicle
                    if currentPacket.licensePlateNumber != hlp {
                        detectType = .uncertain
                        identifiersHashTable.updateValue(e.element, forKey: currentPacket.licensePlateNumber)
                        identifiersHashTable.updateValue(currentPacket, forKey: e.element.licensePlateNumber)
                    }
                    
                    // Save Detection Data For Reporting Later
                    saveData(currentPacket, detectType: detectType)
                    
                    // Find out the verbal location in order to fill detection details
                    let coord = CLLocationCoordinate2D(latitude: currentPacket.latitude, longitude: currentPacket.longitude)
                    self.dropDelegate.lookUpCurrentLocation(coord: coord, completionHandler: { (placemarks) in
                        self.setPlacemarks(placemarks, packet: currentPacket)
                    })
                    
                    // Marked processed to prevent multiple saving
                    currentPacket.isProcessed = true
                    
                    // Check if already proccessed as zone from the past
                    if e.element.isProcessed == false {
                        
                        // Packet from the past but first time to be connected to other packet
                        // This mark is to prevent doubling
                        e.element.isProcessed = true
                        
                        // Save Detection Data For Reporting Later
                        saveData(e.element, detectType: detectType)
                        
                        identifiersHashTable.updateValue(e.element, forKey: e.element.licensePlateNumber)
                        let coordHist = CLLocationCoordinate2D(latitude: e.element.latitude, longitude: e.element.longitude)
                        self.dropDelegate.lookUpCurrentLocation(coord: coordHist, completionHandler: { (placemarks) in
                            self.setPlacemarks(placemarks, packet: e.element)
                        })
                    }
                    
                    // Now We can perform update view action in main thread
                    DispatchQueue.main.async {
                        
                        // Handle Annotation adding to view - Represents the new zone where detection occured [detect of the same lp from the present]
                        let coord = CLLocationCoordinate2D(latitude: currentPacket.latitude, longitude: currentPacket.longitude)
                        self.dropDelegate.addAnnotationForDetected(uuid: currentPacket.id, location: coord, title: currentPacket.licensePlateNumber, type: detectType)
                        
                        if detectType == .uncertain {
                            self.uncertainPreviewDetailsArray.append(currentPacket)
                        } else {
                            // Add this packet for the preview window in view
                            self.appendNewDFW(packet: currentPacket, revive: false)
                        }
                        
                        // Handle Annotation adding to view - Historic detection [detect of the same lp from the past]
                        if !e.element.alreadyDetected {
                            e.element.alreadyDetected = true
                            let coord2 = CLLocationCoordinate2D(latitude: e.element.latitude, longitude: e.element.longitude)
                            self.dropDelegate.addAnnotationForDetected(uuid: e.element.id ,location: coord2, title: e.element.licensePlateNumber, type: detectType)
                            
                            if detectType == .uncertain {
                                self.uncertainPreviewDetailsArray.append(e.element)
                            } else {
                                // Add this packet for the preview window in view [this is the detection from the past]
                                self.appendNewDFW(packet: e.element, revive: false)
                            }
                        }
                    }
                }
                
                break
            }
        }
        
        /*for i in 0...substrings.count-1 {
         currentHashTable.updateValue(currentPacket, forKey: substrings[i])
         //print("\(i): \(array[i])")
         }*/
    }
    
    
    private func divLeft(array: inout [String], key: String){
        let length = key.count
        array.append(key)
        
        if length <= 3 {
            return
        }
        
        let prefix = String(key.prefix(length - 1))
        let suffix = String(key.suffix(length - 1))
        divLeft(array: &array, key: prefix)
        divRight(array: &array, key: suffix)
    }
    
    private func divRight(array: inout [String], key: String) {
        let length = key.count
        array.append(key)
        
        if length <= 3 {
            return
        }
        
        let suffix = String(key.suffix(length - 1))
        divRight(array: &array, key: suffix)
    }
    
    func div(array: inout [String], key: String){
        let length = key.count
        let prefix = String(key.prefix(length - 1))
        let suffix = String(key.suffix(length - 1))
        array.insert(key, at: 0)
        if length > 3 {
            divLeft(array: &array, key: prefix)
            divRight(array: &array, key: suffix)
        }
        array = array.sorted { $0.count > $1.count }
    }
}
