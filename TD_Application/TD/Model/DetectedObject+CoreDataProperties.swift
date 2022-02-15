//
//  DetectedObject+CoreDataProperties.swift
//  TD
//
//  Created by Sharon Wolfovich on 07/03/2021.
//
//

import Foundation
import CoreData


extension DetectedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DetectedObject> {
        return NSFetchRequest<DetectedObject>(entityName: "DetectedObject")
    }

    @NSManaged public var licenseNumber: String?
    @NSManaged public var model: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var year: String?
    @NSManaged public var detectType: Int32
    @NSManaged public var locations: NSSet?

    public var locationArray: [LocationData] {
        let set = locations as? Set<LocationData> ?? []
        
        return set.sorted {
            $0.timeStamp! < $1.timeStamp!
        }
    }
    
    var dType: DetectedAnnotation.DetectType {
            get {
                return DetectedAnnotation.DetectType(rawValue: Int(self.detectType))!
            }
            set {
                self.detectType = Int32(newValue.rawValue)
            }
        }
}

// MARK: Generated accessors for locations
extension DetectedObject {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: LocationData)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: LocationData)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension DetectedObject : Identifiable {

}
