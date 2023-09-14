import XCTest
import SwiftUI
@testable import FlowMagic_SDK

final class FlowMagicSDKTests: XCTestCase {
    /// Tests the registration of a screen with given name and port names and ensures they're correctly stored.
    func testRegisterScreens() {
        // Given
        let mockScreenFlowProvider = ScreenFlowProvider()
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

    /// Tests the behavior of overwriting an existing screen registration and ensures port names remain unchanged.
    func testOverwriteScreen() {
        // Given
        let mockScreenFlowProvider = ScreenFlowProvider()
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

    /// Tests the addition of a connection between screens through ports and validates the correct destination screen retrieval.
    func testAddConnections() {
        // Given
        let mockScreenFlowProvider = ScreenFlowProvider()
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
}
