//
//  File.swift
//  
//
//  Created by Kedar Dhere on 10/7/23.
//

import Foundation
import CoreData

public protocol CoreDataViewModelProtocol {
    func loadContainer(storeType: String)
    func fetchScreenFlows() -> [ScreenFlowEntity]
    func addScreenFlow(source: String, destination: String)
    func saveData()
}

public class CoreDataViewModel: CoreDataViewModelProtocol {
    // MARK: Properties

    let screenFlowContainer : NSPersistentContainer
    public static var sharedCoreDataViewModel = CoreDataViewModel(storeType: NSSQLiteStoreType)

    // MARK: Initialization

    init(storeType: String) {
        let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        self.screenFlowContainer = NSPersistentContainer(name: "Model", managedObjectModel: managedObjectModel!)
//        loadContainer(storeType: String)
        loadContainer(storeType: storeType)
    }

    // MARK: Methods

    public func loadContainer(storeType: String) {
        let description = NSPersistentStoreDescription()
        description.type = storeType
        screenFlowContainer.persistentStoreDescriptions = [description]
        screenFlowContainer.loadPersistentStores{ description, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }

    /// Fetches all the ScreenFlowEntity objects
    public func fetchScreenFlows() -> [ScreenFlowEntity]{
//        let request = NSFetchRequest<ScreenFlowEntity>(entityName: Constants.Entities.screenFlowEntity)
        let request : NSFetchRequest<ScreenFlowEntity> = ScreenFlowEntity.fetchRequest()
        do {
            return try screenFlowContainer.viewContext.fetch(request)
        } catch let error {
            print("Error \(error)")
        }
        return []
    }
    
    /// Add a new Screen Flow to the Core Data entity
    public func addScreenFlow(source: String, destination: String) {
//        if let existingFlow = fetchScreenFlows().first(where: { $0.sourceScreen == source }) {
//            existingFlow.destinationScreen = destination
//        } else {
//            let newScreenFlow = ScreenFlowEntity(context: screenFlowContainer.viewContext)
//            newScreenFlow.sourceScreen = source
//            newScreenFlow.destinationScreen = destination
//        }
        let request: NSFetchRequest<ScreenFlowEntity> = ScreenFlowEntity.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "sourceScreen == %@", source)
        request.predicate = predicate

        if let result = try? screenFlowContainer.viewContext.fetch(request), let existingFlow = result.first {
            existingFlow.destinationScreen = destination
        } else {
            let newScreenFlow = ScreenFlowEntity(context: screenFlowContainer.viewContext)
            newScreenFlow.sourceScreen = source
            newScreenFlow.destinationScreen = destination
        }
        saveData()
    }
    
    /// Save data to ScreenFlowEntity
    public func saveData() {
        do {
            try screenFlowContainer.viewContext.save()
        } catch let error {
            print("Error in saving data to entity \(error)")
        }
    }

    /// Update data
    func updateScreenFlowEntity(source: String, destination: String) {
        let savedScreenFlowEntity = fetchScreenFlows()
        guard !savedScreenFlowEntity.isEmpty else {
            print("No Data saved in Core Data")
            return
        }

        // Update the CoreData ScreenFlow
        let entityToUpdate = savedScreenFlowEntity.filter { $0.sourceScreen == source }
        for entity in entityToUpdate {
            entity.destinationScreen = destination
        }
        saveData()

        //Update the destinationViewsFromPorts
        let screens = ScreenFlowProvider.shared.getScreens()
        guard screens[destination] != nil else {
            print("No Scren registered for \(destination)")
            return
        }
        let destinationView = screens[destination]!.0
        ScreenFlowProvider.shared.updateDestinationViewsFromPorts(portName: source, destinationScreen: destination, destinationView: destinationView)
    }

    /// Reset Core Data
    func deleteData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ScreenFlowEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest )

        do {
            try screenFlowContainer.persistentStoreCoordinator .execute(deleteRequest, with: screenFlowContainer.viewContext)
        } catch let error as NSError {
            print("Error \(error)")
        }
    }
}
