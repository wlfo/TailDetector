//
//  DataManager.swift
//  TD
//
//  Created by Sharon Wolfovich on 15/02/2021.
//

import Foundation
import CoreData
import SwiftUI

class DataManager {
    
    let context: NSManagedObjectContext
    static let shared = DataManager()
    
    
    private init(){
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        self.context = delegate.persistentContainer.viewContext
    }
    
    func contains(uuid: UUID) -> Bool{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationData")
        fetchRequest.includesSubentities = false
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "uuid", uuid as CVarArg)
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try self.context.count(for: fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return entitiesCount > 0
        
    }
    
    func delete(annotationData: AnnotationData) {
        context.delete(annotationData)
    }
    
    
}
