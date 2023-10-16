//
//  File.swift
//  
//
//  Created by Kedar Dhere on 10/9/23.
//

import Foundation
import SwiftUI
import CoreData

enum StoreType {
    case inMemory, persisted
}

public class StorageProvider {
    let persistentContainer: NSPersistentContainer

    init(storeType: StoreType = .persisted) {
        let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!

        persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: managedObjectModel)

        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
    }
}

extension StorageProvider {

    /// Update the screenFlow in CoreData
    func updateScreenFlow(source: String, destination: String) {
        let savedScreenFlow = getScreenFlow(source: source, destination: destination)
        savedScreenFlow.first?.destinationScreen = destination
        saveScreenFlow()
    }

    /// Retrieve all saved data from CoreData
    func getAllScreenFlows() -> [ScreenFlow] {
        let fetchRequest: NSFetchRequest<ScreenFlow> = ScreenFlow.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch screenFlows: \(error)")
            return []
        }
    }

    /// Save the screenFlow to CoreData
    func saveScreenFlow() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }

    /// Return the screenFlow for the specified sourceScreen
    func getScreenFlow(source: String, destination: String) -> [ScreenFlow]{
        let fetchRequest: NSFetchRequest<ScreenFlow> = ScreenFlow.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "sourceScreen == %@", source)
        fetchRequest.predicate = predicate

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch screenFlows: \(error)")
            return []
        }
    }

    /// Update the destinationViewsFromPorts based on the latest changes in CoreData
    func fetchAndUpdate(screenFlowProvider: ScreenFlowProviding) {
        let updatedScreenFlow = getAllScreenFlows()
        let screens = screenFlowProvider.getScreens()

        for entity in updatedScreenFlow {
            let screenInfo = screens[entity.destinationScreen!]
            let destinationView: AnyView = screenInfo!.0
            screenFlowProvider.updateDestinationViewsFromPorts(portName: entity.sourceScreen!, destinationView: destinationView, destinationScreenName: entity.destinationScreen!)
        }
    }

    /// Add newScreen Flow to CoreData
    /// This method will be called only once.
    func addScreenFlow(source: String, destination: String) {
        let savedScreenFlow = getScreenFlow(source: source, destination: destination)

        if savedScreenFlow.isEmpty {
            let screenFlow = ScreenFlow(context: persistentContainer.viewContext)
            screenFlow.sourceScreen = source
            screenFlow.destinationScreen = destination
        }
        saveScreenFlow()
    }
}
