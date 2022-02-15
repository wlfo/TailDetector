//
//  Camera.swift
//  TD
//
//  Created by Sharon Wolfovich on 06/07/2021.
//

import Foundation
import CoreData

public class Camera: NSManagedObject, Identifiable {
    @NSManaged public var deviceSerialNumber: String
    @NSManaged public var location: String
    @NSManaged public var videoDeviceNumber: Int32
    
    override init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: insertInto)
    }
    
    convenience init(context: NSManagedObjectContext, deviceSerialNumber: String, location: String, videoDeviceNumber: Int32) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Camera", in: context)
        
        self.init(entity: entityDescription!, insertInto: context)
        self.deviceSerialNumber = deviceSerialNumber
        self.location = location
        self.videoDeviceNumber = videoDeviceNumber
    }
}


extension Camera {
    static func getAllCameras()-> NSFetchRequest<Camera> {
        let request: NSFetchRequest<Camera> = Camera.fetchRequest() as! NSFetchRequest<Camera>
        let sortDescriptor = NSSortDescriptor(key: "videoDeviceNumber", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    
}
