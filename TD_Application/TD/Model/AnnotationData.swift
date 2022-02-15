//
//  AnnotationData.swift
//  TD
//
//  Created by Sharon Wolfovich on 11/02/2021.
//

import Foundation
import CoreData

public class AnnotationData: NSManagedObject, Identifiable {
    @NSManaged public var uuid: UUID
    @NSManaged public var index: Int32
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var title: String?
    
    override init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: insertInto)
    }
    
    
    
    convenience init(context: NSManagedObjectContext, longitude: Double, latitude: Double, title: String, index: Int32) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "AnnotationData", in: context)
        
        
        self.init(entity: entityDescription!, insertInto: context)
        self.uuid = UUID()
        self.index = index
        self.longitude = longitude
        self.latitude = latitude
        self.title = title
    }
    
}


extension AnnotationData {
    static func getAllAnnotationData()-> NSFetchRequest<AnnotationData> {
        let request: NSFetchRequest<AnnotationData> = AnnotationData.fetchRequest() as! NSFetchRequest<AnnotationData>
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    
}
