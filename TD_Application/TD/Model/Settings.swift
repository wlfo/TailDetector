//
//  Settings.swift
//  TD
//
//  Created by Sharon Wolfovich on 31/05/2021.
//

import Foundation
import CoreData

public class Settings: NSManagedObject, Identifiable {
    @NSManaged public var inRadius: Int32
    @NSManaged public var radius: Int32
    
    override init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: insertInto)
    }
    
    convenience init(context: NSManagedObjectContext, inRadius: Int32, radius: Int32) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Settings", in: context)
        
        self.init(entity: entityDescription!, insertInto: context)
        self.inRadius = inRadius
        self.radius = radius
    }
}


extension Settings {
    static func getAllSettings()-> NSFetchRequest<Settings> {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest() as! NSFetchRequest<Settings>
        let sortDescriptor = NSSortDescriptor(key: "radius", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    
}
