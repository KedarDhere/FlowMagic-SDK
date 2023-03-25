////
////  ScreenFlowTests.swift
////  FlowMagic-SDKTests
////
////  Created by Kedar Dhere on 3/24/23.
////
//
import XCTest
import SwiftUI
@testable import FlowMagic_SDK

class MockScreenProvider: ScreenFlowProviding {

    // MARK: - Properties

    var screens: [String: (view: AnyView, portNames: [String])]
    var destinationViewsFromPorts: [String: AnyView?]

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

class MockFlowMagicViewModel: FlowMagicViewModel {

    private var service: Webservice
    var mockScreenProvider = MockScreenProvider()

    // MARK: Initialization
    // MARK: Initialization
    override init(service: Webservice) {
        self.service = service
        super.init(service: Webservice())
    }

    override func load() async {
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
        do {
//            let screenFlowData = try decoder.decode(ScreenFlowModel.self, from: mockScreenFlowData)
            let screenFlowData = try service.loadMockData()
            var destinationView: AnyView = ProgressView().toAnyView()
            for screen in screenFlowData!.applicationScreenFlow {
                let screenInfo = mockScreenProvider.screens[screen.destinationView]
                destinationView = screenInfo!.0
                mockScreenProvider.updateDestinationViewsFromPorts(
                    portName: screen.portName, destinationView: destinationView
                )
            }
        } catch {
            print(error)
        }
    }
}

final class ScreenFlowTests: XCTestCase {
    func test1() {

        var destinationViewsFromPorts: [String: any View] = [:]

        destinationViewsFromPorts = [
            "Home.SignUp": RandomPage()
        ]

        let actual = destinationViewsFromPorts["Home.SignUp"]
    //    let expected = AnyView(RandomPage())
        actual is SignUp
    }

    @MainActor func test2() {
        let mockScreenFlowProvider = MockScreenProvider()
        let mockScreenFlowViewModel = MockFlowMagicViewModel(service: Webservice())

        mockScreenFlowProvider.registerScreen(screenName: "Home", portNames: ["SignUp", "Login", "RandomPage"], view: Home())
        mockScreenFlowProvider.registerScreen(screenName: "SignUp", portNames: [], view: SignUp())
        mockScreenFlowProvider.registerScreen(screenName: "Login", portNames: [], view: Login())
        mockScreenFlowProvider.registerScreen(screenName: "RandomPage", portNames: [], view: RandomPage())
        
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "SignUp")
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "Login")
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "RandomPage")

        let actual = mockScreenFlowProvider.getDestinationScreen(portName: "Home.SignUp")
        let expected = SignUp()

        actual is SignUp

    }

}
