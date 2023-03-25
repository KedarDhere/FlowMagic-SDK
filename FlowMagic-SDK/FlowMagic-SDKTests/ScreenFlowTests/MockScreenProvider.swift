////
////  MockScreenProvider.swift
////  FlowMagic-SDK
////
////  Created by Kedar Dhere on 3/25/23.
////
//

import SwiftUI
import Foundation
import FlowMagic_SDK

//class MockScreenProvider: ScreenFlowProvider {
//
//    // MARK: - Initialization
//
//    override init() {
//    }
//
//    override func registerScreen(screenName: String, portNames: [String], view: any View) {
//        guard screens[screenName] == nil else {
//            return
//        }
//
//        screens[screenName] = (AnyView(view), portNames)
//    }
//
//    override func addConnection(fromPort: String, toScreen: String) {
//        guard let view = screens[toScreen]?.view else {
//            fatalError("Value of screen is nil")
//        }
//
//        let portName = fromPort + "." + toScreen
//        destinationViewsFromPorts[portName] = view
//    }
//
//    override func getDestinationScreen(portName: String) -> any View {
//        return destinationViewsFromPorts[portName]
//    }
//}

//class MockScreenProvider: ScreenFlowProviding {
//
//    // MARK: - Properties
//
//    var screens: [String: (view: AnyView, portNames: [String])]
//    var destinationViewsFromPorts: [String: AnyView?]
//
//    // MARK: - Initialization
//
//    init() {
//        screens = [:]
//        destinationViewsFromPorts = [:]
//    }
//
//    func registerScreen(screenName: String, portNames: [String], view: any View) {
//        guard screens[screenName] == nil else {
//            return
//        }
//
//        screens[screenName] = (AnyView(view), portNames)
//    }
//
//    func addConnection(fromPort: String, toScreen: String) {
//        guard let view = screens[toScreen]?.view else {
//            fatalError("Value of screen is nil")
//        }
//
//        let portName = fromPort + "." + toScreen
//        destinationViewsFromPorts[portName] = view
//    }
//
//    func getDestinationScreen(portName: String) -> any View {
//        return destinationViewsFromPorts[portName]
//    }
//
//    func getScreens() -> [String: (view: AnyView, portNames: [String])] {
//        return screens
//    }
//
//    func getDestinationViewsFromPorts() -> [String: AnyView?] {
//        return destinationViewsFromPorts
//    }
//
//    func updateDestinationViewsFromPorts(portName: String, destinationView: AnyView) {
//        destinationViewsFromPorts[portName] = destinationView
//    }
//}
//
//class MockFlowMagicViewModel: FlowMagicViewModel {
//
//    var mockScreenProvider = MockScreenProvider()
//    override func load() async {
//        let mockScreenFlowData = """
//        {
//            "applicationId": "66ceb688a2b311eda8fc0242ac120002",
//            "applicationScreenFlow": [
//              {
//                "screenName": "Home",
//                "portName": "Home.RandomPage",
//                "destinationView": "RandomPage"
//              },
//              {
//                "screenName": "Login",
//                "portName": "Home.Login",
//                "destinationView": "SignUp"
//              },
//              {
//                "screenName": "SignUp",
//                "portName": "Home.SignUp",
//                "destinationView": "RandomPage"
//              }
//            ]
//        }
//        """.data(using: .utf8)!
//
//        let decoder = JSONDecoder()
//        do {
//            let screenFlowData = try decoder.decode(ScreenFlowModel.self, from: mockScreenFlowData)
//            var destinationView: AnyView = ProgressView().toAnyView()
//            for screen in screenFlowData.applicationScreenFlow {
//                let screenInfo = mockScreenProvider.screens[screen.destinationView]
//                destinationView = screenInfo!.0
//                mockScreenProvider.updateDestinationViewsFromPorts(
//                    portName: screen.portName, destinationView: destinationView
//                )
//            }
//        } catch {
//            print(error)
//        }
//    }
//}
