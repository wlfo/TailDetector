//
//  LocationData+CoreDataProperties.swift
//  TD
//
//  Created by Sharon Wolfovich on 07/03/2021.
//
//

import Foundation
import CoreData


extension LocationData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationData> {
        return NSFetchRequest<LocationData>(entityName: "LocationData")
    }

    @NSManaged public var image: Data?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timeStamp: Date?
    @NSManaged public var ofDetectedObject: DetectedObject?

}

extension LocationData : Identifiable {

}
