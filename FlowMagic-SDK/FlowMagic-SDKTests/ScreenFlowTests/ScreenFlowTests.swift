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

func propertiesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    let lhsMirror = Mirror(reflecting: lhs)
    let rhsMirror = Mirror(reflecting: rhs)

    for (lhsChild, rhsChild) in zip(lhsMirror.children, rhsMirror.children) {
        guard "\(lhsChild.value)" == "\(rhsChild.value)" else { return false }
    }
    return true
}

class ScreenFlowTests: XCTestCase {
     // Test Register Screen and Get Screen
    func testRegisterScreens() {
        // Given
        let mockScreenFlowProvider = MockScreenProvider()
        let screenName = "Home"
        let portNames = ["Login", "SignUp"]
        let view = AnyView(Home())

        // When
        mockScreenFlowProvider.registerScreen(screenName: screenName, portNames: portNames, view: view)

        // Then
        let expectedOutput = mockScreenFlowProvider.getScreens()
        XCTAssertNotNil(expectedOutput[screenName], "Screen with name \(screenName) not found.")
        XCTAssertEqual(expectedOutput[screenName]?.1, portNames,
                       "Screen's portNames are different than the input portnames")
    }

    // Test if screen Name is blank while registering the screens
    func testOverwriteScreen() {
        // Given
        let mockScreenFlowProvider = MockScreenProvider()
        let screenName = "Home"
        let initialPortNames = ["Login", "SignUp"]
        let overwrittenPortNames = ["Login", "SignUp", "AnotherPage"]
        let view = AnyView(Home())

        // Register the screen initially
        mockScreenFlowProvider.registerScreen(screenName: screenName, portNames: initialPortNames, view: view)

        // Try overwriting the screen
        mockScreenFlowProvider.registerScreen(screenName: screenName, portNames: overwrittenPortNames, view: view)

        // Then
        let screenInfo = mockScreenFlowProvider.getScreens()[screenName]
        XCTAssertNotNil(screenInfo)
        XCTAssertEqual(screenInfo?.1, initialPortNames)
    }

    // Test Adding Connections
    func testAddConnections() {
        // Given
        let mockScreenFlowProvider = MockScreenProvider()
        let homeScreen = "Home"
        let homeScrPortNames = ["Login", "SignUp"]
        let home = AnyView(Home())

        let signUpScreen = "SignUp"
        let signUpScrPortNames = [String()]
        let signUp = AnyView(SignUp())

        let portName = "Home.SignUp"

        // Register the screen initially
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScrPortNames, view: home)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUp)

        // When
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "SignUp")

        // Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: portName)
        XCTAssertNotNil(expectedOutput, "PortNames are not added as expected")
    }

    // Add connection prior to registering the screen
    func testAddConnectionWithNoRegistration() {
        // Given
        let mockScreenFlowProvider = MockScreenProvider()
        let homeScreen = "Home"
        let homeScrPortNames = ["Login", "SignUp"]
        let home = AnyView(Home())
        let mockErrorHandler = MockHandleFatalError()
        mockScreenFlowProvider.mockErrorHandler = mockErrorHandler

        // Register only the Home screen
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScrPortNames, view: home)

        // When
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "SignUp")

        // Then
        XCTAssertTrue(mockErrorHandler.didHandleFatalError)
        XCTAssertEqual(mockErrorHandler.errorMessage, "Value of screen is nil")
    }

    // Test Screen Flow updation
    func testUpdateScreenFlow() {
        // Given
        let mockScreenFlowProvider = MockScreenProvider()
        let homeScreen = "Home"
        let homeScrPortNames = ["SignUp"]
        let homeView = AnyView(Home())

        let signUpScreen = "SignUp"
        let signUpScrPortNames = [String()]
        let signUpView = AnyView(SignUp())

        let loginScreen = "Login"
        let loginScrPortNames = [String()]
        let loginView = AnyView(Login())

        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScrPortNames, view: homeView)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUpView)
        mockScreenFlowProvider.registerScreen(screenName: loginScreen, portNames: loginScrPortNames, view: loginView)

        // Add Connection
        mockScreenFlowProvider.addConnection(fromPort: homeScreen, toScreen: signUpScreen)

        // When
        mockScreenFlowProvider.updateDestinationViewsFromPorts(
            portName: "Home.SignUp",
            destinationView: AnyView(Login()))

        // Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: "Home.SignUp")
        let actualOutput = AnyView(Login())
        XCTAssertTrue(propertiesAreEqual(expectedOutput, actualOutput))
    }

    // Test the viewModel
    @MainActor func testViewModel() async {
        // Given
        let mockScreenFlowProvider = MockScreenProvider()
        let viewModel = FlowMagicViewModel(service: MockWebService(), screenFlowProvider: mockScreenFlowProvider)

        let homeScreen = "Home"
        let homeScrPortNames = ["SignUp"]
        let homeView = AnyView(Home())

        let signUpScreen = "SignUp"
        let signUpScrPortNames = [String()]
        let signUpView = AnyView(SignUp())

        let loginScreen = "Login"
        let loginScrPortNames = [String()]
        let loginView = AnyView(Login())

        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScrPortNames, view: homeView)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUpView)
        mockScreenFlowProvider.registerScreen(screenName: loginScreen, portNames: loginScrPortNames, view: loginView)

        mockScreenFlowProvider.addConnection(fromPort: homeScreen, toScreen: signUpScreen)
        mockScreenFlowProvider.registerScreen(screenName: loginScreen, portNames: [], view: Login())
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: [], view: SignUp())

        // When
        await viewModel.load()

        // Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: "Home.Login")
        let actualOutput = AnyView(SignUp())
        XCTAssertTrue(propertiesAreEqual(expectedOutput, actualOutput))
    }
}
