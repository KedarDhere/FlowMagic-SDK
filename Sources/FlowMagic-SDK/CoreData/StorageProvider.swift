//
//  File.swift
//  
//
//  Created by Kedar Dhere on 10/9/23.
//

import Foundation
import SwiftUI
import CoreData

public class StorageProvider {
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
        let savedScreenFlow = getScreenFlow(source: source, destination: destination)

//        if savedScreenFlow.isEmpty {
//            let screenFlow = ScreenFlow(context: persistentContainer.viewContext)
//            screenFlow.sourceScreen = source
//            screenFlow.destinationScreen = destination
//        } else {
            savedScreenFlow.first?.sourceScreen = destination
//        }

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
    func fetchAndUpdate() {
        let updatedScreenFlow = getAllScreenFlows()
//        var localScreenFlow = ScreenFlowProvider.shared.getDestinationViewsFromPorts()
        let screens = ScreenFlowProvider.shared.getScreens()

        for entity in updatedScreenFlow {
            var screenInfo = screens[entity.destinationScreen!]
            var destinationView: AnyView = screenInfo!.0
            ScreenFlowProvider.shared.updateDestinationViewsFromPorts(portName: entity.sourceScreen!, destinationView: destinationView, destinationScreenName: entity.destinationScreen!)
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
