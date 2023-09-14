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
}
