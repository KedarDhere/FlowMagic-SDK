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

    func updateScreenFlow(source: String, destination: String) {
        let savedScreenFlow = getScreenFlow(source: source, destination: destination)
        savedScreenFlow.first?.destinationScreen = destination

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

    /// Update the destinationViewsFromPorts as per the latest changes in the CoreData
    func fetchAndUpdate(screenFlowProvider: ScreenFlowProviding) {
        let updatedScreenFlow = getAllScreenFlows()
        let screens = screenFlowProvider.getScreens()

        for entity in updatedScreenFlow {
            let screenInfo = screens[entity.destinationScreen!]
            let destinationView: AnyView = screenInfo!.0
            screenFlowProvider.updateDestinationViewsFromPorts(portName: entity.sourceScreen!, destinationView: destinationView, destinationScreenName: entity.destinationScreen!)
        }
    }

    /// The following method will call only once
    func addScreenFlow(source: String, destination: String) {
        let savedScreenFlow = getScreenFlow(source: source, destination: destination)

        if savedScreenFlow.isEmpty {
            let screenFlow = ScreenFlow(context: persistentContainer.viewContext)
            screenFlow.sourceScreen = source
            screenFlow.destinationScreen = destination
        }

        do {
            try persistentContainer.viewContext.save()
            print("Screen Flow saved successfully")
        } catch {
            print("Failed to save screenFlow: \(error)")
        }
    }
}
