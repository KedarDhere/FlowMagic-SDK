import XCTest
import SwiftUI
@testable import FlowMagic_SDK

func propertiesAreEqual(_ lhs: Any?, _ rhs: Any?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil):
        return true
    case (let lhsValue as AnyView, let rhsValue as AnyView):
        return "\(lhsValue)" == "\(rhsValue)"
    default:
        return false
    }
}

final class FlowMagicSDKTests: XCTestCase {
    /// Tests the registration of a screen with given name and port names and ensures they're correctly stored.
    func testRegisterScreens() {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider())
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
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider())
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
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider())
        let homeScreen = "Home"
        let homeScreenPortNames = ["Login", "SignUp"]
        let home = AnyView(Home())

        let signUpScreen = "SignUp"
        let signUpScrPortNames = [String()]
        let signUp = AnyView(SignUp())

        let portName = "Home.SignUp"

        // Register the screen initially
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: home)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUp)

        // When
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "SignUp")

        // Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: portName)
        XCTAssertNotNil(expectedOutput, "PortNames are not added as expected")
    }

    /// Tests the behavior when attempting to add a connection to an unregistered screen and expects an error.
    func testAddConnectionWithNoRegistration() {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider())
        let homeScreen = "Home"
        let homeScreenPortNames = ["Login", "SignUp"]
        let home = AnyView(Home())

        // Register only the Home screen
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: home)

        // When
        mockScreenFlowProvider.addConnection(fromPort: "Home", toScreen: "SignUp")

        // Then
        XCTAssertTrue(mockErrorHandler.didHandleFatalError)
        XCTAssertEqual(mockErrorHandler.errorMessage, "Value of screen is nil")
    }

    /// Tests the functionality of updating the destination views of screen connections.
    func testUpdateScreenFlow() {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider())
        let homeScreen = "Home"
        let homeScreenPortNames = ["SignUp"]
        let homeView = AnyView(Home())

        let signUpScreen = "SignUp"
        let signUpScrPortNames = [String()]
        let signUpView = AnyView(SignUp())

        let loginScreen = "Login"
        let loginScrPortNames = [String()]
        let loginView = AnyView(Login())

        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUpView)
        mockScreenFlowProvider.registerScreen(screenName: loginScreen, portNames: loginScrPortNames, view: loginView)

        // Add Connection
        mockScreenFlowProvider.addConnection(fromPort: homeScreen, toScreen: signUpScreen)

        // When
        mockScreenFlowProvider.updateDestinationViewsFromPorts(
            portName: "Home.SignUp",
            destinationView: AnyView(Login()), destinationScreenName: "Login")

        // Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: "Home.SignUp")
        let actualOutput = AnyView(Login())
        XCTAssertTrue(propertiesAreEqual(expectedOutput, actualOutput))
    }

    /// Tests the FlowMagicViewModel's screen registration and connection rendering behavior.
    @MainActor func testViewModel() async {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider())
        let viewModel = FlowMagicViewModel(service: MockWebService(), screenFlowProvider: mockScreenFlowProvider)

        let homeScreen = "Home"
        let homeScreenPortNames = ["SignUp"]
        let homeView = AnyView(Home())

        let signUpScreen = "SignUp"
        let signUpScrPortNames = [String()]
        let signUpView = AnyView(SignUp())

        let loginScreen = "Login"
        let loginScrPortNames = [String()]
        let loginView = AnyView(Login())

        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)
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

    /// Tests the Web service class
    func testWebService() async throws {
        // Given
        let mockSession = MockNetworkSession()
        let service = WebServiceImpl(networkSession: mockSession)
        let jsonData = """
        {
            "applicationId": "66ceb688a2b311eda8fc0242ac120002",
            "applicationScreenFlow": [
                {
                    "screenName": "Home",
                    "portName": "Home.RandomPage",
                    "destinationView": "RandomPage"
                },
                {
                    "screenName": "Login",
                    "portName": "Home.Login",
                    "destinationView": "SignUp"
                },
                {
                    "screenName": "SignUp",
                    "portName": "Home.SignUp",
                    "destinationView": "RandomPage"
                }
            ]
        }
        """.data(using: .utf8)!

        let mockURL = URL(string: "http://test.com")!
        let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = jsonData
        mockSession.mockResponse = mockResponse

        // When
        let screenFlowModel = try await service.loadUrlData(resource: "http://test.com")

        // Then
        XCTAssertEqual(screenFlowModel.applicationId, "66ceb688a2b311eda8fc0242ac120002")
        XCTAssertEqual(screenFlowModel.applicationScreenFlow[0].screenName, "Home")
        XCTAssertEqual(screenFlowModel.applicationScreenFlow[0].portName, "Home.RandomPage")
        XCTAssertEqual(screenFlowModel.applicationScreenFlow[0].destinationView, "RandomPage")
    }
}
