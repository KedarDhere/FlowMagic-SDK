////
////  MockScreenProvider.swift
////  FlowMagic-SDK
////
////  Created by Kedar Dhere on 3/25/23.
////
//

import SwiftUI
import Foundation
@testable import FlowMagic_SDK

enum ScreenProviderError: Error {
    case screenNotFound
}

class MockHandleFatalError: ErrorHandlerProtocol {
    var didHandleFatalError = false
    var errorMessage: String?

    func handleFatalError(_ message: String) {
        didHandleFatalError = true
        errorMessage = message
    }
}

class MockScreenProvider: ScreenFlowProviding {

    // MARK: - Properties

    var screens: [String: (view: AnyView, portNames: [String])]
    var destinationViewsFromPorts: [String: any View]
    var mockErrorHandler: ErrorHandlerProtocol = MockHandleFatalError()

    // MARK: - Initialization

    init() {
        screens = [:]
        destinationViewsFromPorts = [:]
    }

    func registerScreen(screenName: String, portNames: [String], view: any View) {
        guard screens[screenName] == nil else {
            return
        }

        screens[screenName] = (AnyView(view), portNames)
    }

    func addConnection(fromPort: String, toScreen: String) {
        guard let view = screens[toScreen]?.view else {
            mockErrorHandler.handleFatalError("Value of screen is nil")
            return
        }

        let portName = fromPort + "." + toScreen
        destinationViewsFromPorts[portName] = view
    }

    func getDestinationScreen(portName: String) -> any View {
        return destinationViewsFromPorts[portName]!
    }

    func getScreens() -> [String: (view: AnyView, portNames: [String])] {
        return screens
    }

    func getDestinationViewsFromPorts() -> [String: any View] {
        return destinationViewsFromPorts
    }

    func updateDestinationViewsFromPorts(portName: String, destinationView: AnyView) {
        destinationViewsFromPorts[portName] = destinationView
    }
}
