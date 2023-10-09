//
//  FlowMagicSDK.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import Foundation
import SwiftUI

public protocol ErrorHandlerProtocol {
    func handleFatalError(_ message: String)
}

public class ProductionHandleFatalError: ErrorHandlerProtocol {
    public func handleFatalError(_ message: String) {
        fatalError(message)
    }
}

class MockErrorHandler: ErrorHandlerProtocol {
    var didHandleFatalError = false
    var errorMessage: String?

    func handleFatalError(_ message: String) {
        didHandleFatalError = true
        errorMessage = message
    }
}

public protocol ScreenFlowProviding {
    func registerScreen(screenName: String, portNames: [String], view: any View)
    func addConnection(fromPort: String, toScreen: String)
    func getDestinationScreen(portName: String) -> any View
    func getScreens() -> [String: (view: AnyView, portNames: [String])]
    func getDestinationViewsFromPorts() -> [String: any View]
    func updateDestinationViewsFromPorts(portName: String, destinationScreen: String, destinationView: AnyView)
}

public class ScreenFlowProvider: ScreenFlowProviding {

    public static var shared = ScreenFlowProvider(errorHandle: ProductionHandleFatalError())
    let errorHandle: ErrorHandlerProtocol
    let userDefaultKey: String = "screenFlow"

    // MARK: - Properties

    public var screens: [String: (view: AnyView, portNames: [String])]
    public var destinationViewsFromPorts: [String: AnyView?]

    // MARK: - Initialization

    public init(errorHandle: ErrorHandlerProtocol) {
        self.errorHandle = errorHandle
        screens = [:]
        destinationViewsFromPorts = [:]
    }

    // MARK: - Methods

    public func registerScreen(screenName: String, portNames: [String], view: any View) {
        guard screens[screenName] == nil else {
            return
        }
        screens[screenName] = (AnyView(view), portNames)
    }

    public func addConnection(fromPort: String, toScreen: String) {
        guard let view = screens[toScreen]?.view else {
            errorHandle.handleFatalError("Value of screen is nil")
            return
        }

        let portName = fromPort + "." + toScreen
        destinationViewsFromPorts[portName] = view
        CoreDataViewModel.sharedCoreDataViewModel.addScreenFlow(source: portName, destination: toScreen)
    }

    public func getDestinationScreen(portName: String) -> any View {
//        updateScreenFlow()
        return destinationViewsFromPorts[portName]
    }

    public func getScreens() -> [String: (view: AnyView, portNames: [String])] {
        return screens
    }

    public func getDestinationViewsFromPorts() -> [String: any View] {
//        updateScreenFlow()
        return destinationViewsFromPorts
    }

    public func updateDestinationViewsFromPorts(portName: String, destinationScreen: String, destinationView: AnyView) {
        if CoreDataViewModel.sharedCoreDataViewModel.screenFlowContainer.viewContext.hasChanges {
            CoreDataViewModel.sharedCoreDataViewModel.updateScreenFlowEntity(source: portName, destination: destinationScreen)
        }
        destinationViewsFromPorts[portName] = destinationView
    }

    public func updateScreenFlow() {
        let newScreenFlow = CoreDataViewModel.sharedCoreDataViewModel.fetchScreenFlows()
        for entity in newScreenFlow {
            guard let view = screens[entity.destinationScreen!]?.view else {
                errorHandle.handleFatalError("Value of screen is nil")
                return
            }
            updateDestinationViewsFromPorts(portName: entity.sourceScreen!, destinationScreen: entity.destinationScreen!, destinationView: view)
        }
    }

}
