//
//  FlowMagicSDK.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import Foundation
import SwiftUI

protocol ScreenFlowProviding {
    func registerScreen(screenName: String, portNames: [String], view: any View)
    func addConnection(fromPort: String, toScreen: String)
    func getDestinationScreen(portName: String) -> any View
}

class ScreenFlowProvider: ScreenFlowProviding {

    static var shared = ScreenFlowProvider()

    // MARK: - Properties

    private var screens: [String: (view: AnyView, portNames: [String])]
    private var destinationViewsFromPorts: [String: AnyView?]

    // MARK: - Initialization

    init() {
        screens = [:]
        destinationViewsFromPorts = [:]
    }

    // MARK: - Methods

    func registerScreen(screenName: String, portNames: [String], view: any View) {
        guard screens[screenName] == nil else {
            return
        }

        screens[screenName] = (AnyView(view), portNames)
    }

    func addConnection(fromPort: String, toScreen: String) {
        guard let view = screens[toScreen]?.view else {
            fatalError("Value of screen is nil")
        }

        let portName = fromPort + "." + toScreen
        destinationViewsFromPorts[portName] = view
    }

    func getDestinationScreen(portName: String) -> any View {
        return destinationViewsFromPorts[portName]
    }

    func getScreens() -> [String: (view: AnyView, portNames: [String])] {
        return screens
    }

    func getDestinationViewsFromPorts() -> [String: AnyView?] {
        return destinationViewsFromPorts
    }

    func updateDestinationViewsFromPorts(portName: String, destinationView: AnyView) {
        destinationViewsFromPorts[portName] = destinationView
    }
}
