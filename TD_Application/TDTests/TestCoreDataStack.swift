//
//  TestCoreDataStack.swift
//  TDTests
//
//  Created by Sharon Wolfovich on 22/02/2021.
//

import Foundation
import CoreData
@testable import TD

class TestCoreDataStack: CoreDataStack {
  override init() {
    super.init()
    self.persistentStoreCoordinator = {
      let psc = NSPersistentStoreCoordinator(
      managedObjectModel: self.managedObjectModel)
      do {
        try psc.addPersistentStore(ofType:
        NSInMemoryStoreType,configurationName: nil,
        at: nil, options:nil)
      } catch {
        fatalError()
      }
      return psc
    }()
  }
}
