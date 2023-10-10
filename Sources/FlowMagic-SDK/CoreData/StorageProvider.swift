//
//  File.swift
//  
//
//  Created by Kedar Dhere on 10/9/23.
//

import Foundation
import CoreData

class StorageProvider {
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "Model")

        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
    }
}
