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

extension StorageProvider {

    func updateScreenFlow(source: String, destination: String) {
        let screenFlow = ScreenFlow(context: persistentContainer.viewContext)
        screenFlow.sourceScreen = source
        screenFlow.destinationScreen = destination

        do {
            try persistentContainer.viewContext.save()
            print("Screen Flow saved successfully")
        } catch {
            print("Failed to save screenFlow: \(error)")
        }
    }

    func getAllScreenFlows() -> [ScreenFlow] {
        let fetchRequest: NSFetchRequest<ScreenFlow> = ScreenFlow.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch screenFlows: \(error)")
            return []
        }
    }

    func saveScreenFlow() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
}
