//
//  AppDelegate.swift
//  TD
//
//  Created by Sharon Wolfovich on 24/01/2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func checkAndExecuteSettings(){
        if UserDefaults.standard.bool(forKey: "clear_cache") {
            UserDefaults.standard.set(false, forKey: "clear_cache")
            let appDomain: String? = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            
            // Remove the existing items
            let managedObjectContext = persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Camera")
            
            var cameras: [Camera]
            do {
                try cameras = managedObjectContext.fetch(fetchRequest) as! [Camera]
                for camera in cameras {
                    managedObjectContext.delete(camera)
                }
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
                
            } catch  {
                print(error)
            }
        }
    }
    
    func removeObjects<T: NSManagedObject>(entity: T.Type, sortKey: String){
        let managedObjectContext = persistentContainer.viewContext
        let entityName = String(describing: entity)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
        fetchRequest.entity = entityDescription
        
        var data: [T]
        do {
            try data = managedObjectContext.fetch(fetchRequest)
            for entry in data {
                managedObjectContext.delete(entry)
            }
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
            
        } catch  {
            print(error)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        checkAndExecuteSettings()
        
        // Delete previous context 
        removeObjects(entity: AnnotationData.self, sortKey: "index")
        removeObjects(entity: DetectedObject.self, sortKey: "uuid")
                
        // Override zone for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TD")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

