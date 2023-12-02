import XCTest
import SwiftUI
@testable import FlowMagic_SDK
import CoreData

let homeScreen = "Home"
let homeView = AnyView(Home())
let homeScreenPortNames = ["Login", "SignUp"]

let signUpScreen = "SignUp"
let signUpView = AnyView(SignUp())
let signUpScrPortNames = [String()]

let loginScreen = "Login"
let loginView = AnyView(Login())
let loginScrPortNames = [String()]

let jsonData = """
{
    "id": "66ceb688a2b311eda8fc0242ac120002",
    "screenFlow": [
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
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider(storeType: .inMemory))

        // When
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)

        // Then
        let expectedOutput = mockScreenFlowProvider.getScreens()
        XCTAssertNotNil(expectedOutput[homeScreen], "Screen with name \(homeScreen) not found.")
        XCTAssertEqual(expectedOutput[homeScreen]?.1, homeScreenPortNames,
                       "Screen's portNames are different than the input portnames")
    }

    /// Tests the behavior of overwriting an existing screen registration and ensures port names remain unchanged.
    func testOverwriteScreen() {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider(storeType: .inMemory))

        let initialPortNames = ["Login", "SignUp"]
        let overwrittenPortNames = ["Login", "SignUp", "AnotherPage"]

        // Register the screen initially
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: initialPortNames, view: homeView)

        // Try overwriting the screen
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: overwrittenPortNames, view: homeView)

        // Then
        let screenInfo = mockScreenFlowProvider.getScreens()[homeScreen]
        XCTAssertNotNil(screenInfo)
        XCTAssertEqual(screenInfo?.1, initialPortNames)
    }

    /// Tests the addition of a connection between screens through ports and validates the correct destination screen retrieval.
    func testAddConnections() {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider(storeType: .inMemory))

        let portName = "Home.SignUp"

        // Register the screen initially
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUpView)

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
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider(storeType: .inMemory))

        // Register only the Home screen
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)

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
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider(storeType: .inMemory))

        let homeScreenPortNames = ["SignUp"]
        let signUpScrPortNames = [String()]
        let loginScrPortNames = [String()]

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
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: StorageProvider(storeType: .inMemory))
        let viewModel = FlowMagicViewModel(service: MockWebService(), screenFlowProvider: mockScreenFlowProvider)

        let homeScreen = "Home"
        let homeScreenPortNames = ["SignUp"]

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

        let mockURL = URL(string: "http://test.com")!
        let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = jsonData
        mockSession.mockResponse = mockResponse

        // When
        let screenFlowModel = try await service.loadUrlData(resource: "http://test.com")

        // Then
        XCTAssertEqual(screenFlowModel.id, "66ceb688a2b311eda8fc0242ac120002")
        XCTAssertEqual(screenFlowModel.screenFlow[0].screenName, "Home")
        XCTAssertEqual(screenFlowModel.screenFlow[0].portName, "Home.RandomPage")
        XCTAssertEqual(screenFlowModel.screenFlow[0].destinationView, "RandomPage")
    }

    func testCoreDataFetch() {
        //Given
        let storage = StorageProvider(storeType: .inMemory)

        // When
        storage.addScreenFlow(source: "Home.SignUp", destination: "Login")
        storage.addScreenFlow(source: "Home.Login", destination: "SignUp")
        let savedData = storage.getAllScreenFlows()

        // Then
        XCTAssertEqual(savedData.count, 2)
        XCTAssertEqual(savedData.first!.sourceScreen, "Home.SignUp")
        XCTAssertEqual(savedData.first!.destinationScreen, "Login")
    }

    func testCoreDataFetchPredicate() {
        //Given
        let storage = StorageProvider(storeType: .inMemory)

        // When
        storage.addScreenFlow(source: "Home.SignUp", destination: "Login")
        storage.updateScreenFlow(source: "Home.SignUp", destination: "RandomPage")
        let retrivedData = storage.getScreenFlow(source: "Home.SignUp", destination: "RandomPage")

        // Then
        XCTAssertEqual(retrivedData.count, 1)
        XCTAssertEqual(retrivedData.first!.sourceScreen, "Home.SignUp")
        XCTAssertEqual(retrivedData.first!.destinationScreen, "RandomPage")
    }

    func testFailureCoreDataFetchPredicate() {
        //Given
        let storage = StorageProvider(storeType: .inMemory)

        // When
        storage.addScreenFlow(source: "Home.SignUp", destination: "Login")
        storage.updateScreenFlow(source: "Home.SignUp", destination: "RandomPage")
        let retrivedData = storage.getScreenFlow(source: "Home.Login", destination: "RandomPage")

        // Then
        XCTAssertEqual(retrivedData.count, 0)
    }

    func testCoreDataUpdation() {
        // Given
        let storage = StorageProvider(storeType: .inMemory)

        // When
        storage.addScreenFlow(source: "Home.SignUp", destination: "Login")
        storage.updateScreenFlow(source: "Home.SignUp", destination: "RandomPage")
        let savedData = storage.getAllScreenFlows()

        // Then
        XCTAssertEqual(savedData.count, 1)
        XCTAssertEqual(savedData.first!.sourceScreen, "Home.SignUp")
        XCTAssertEqual(savedData.first!.destinationScreen, "RandomPage")
    }

    func testSaveData() {
        // Given
        let storage = StorageProvider(storeType: .inMemory)

        // When
        storage.addScreenFlow(source: "Home.SignUp", destination: "Login")
        storage.updateScreenFlow(source: "Home.SignUp", destination: "RandomPage")
        storage.saveScreenFlow()
        let savedData = storage.getAllScreenFlows()

        // Then
        XCTAssertEqual(savedData.count, 1)
        XCTAssertEqual(savedData.first!.sourceScreen, "Home.SignUp")
        XCTAssertEqual(savedData.first!.destinationScreen, "RandomPage")

    }

    func testFetchAndUpdate() {
        // Given
        let storage = StorageProvider(storeType: .inMemory)
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: storage)

        // When
        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUpView)
        mockScreenFlowProvider.registerScreen(screenName: loginScreen, portNames: loginScrPortNames, view: loginView)

        storage.addScreenFlow(source: "Home.SignUp", destination: "SignUp")
        storage.addScreenFlow(source: "Home.Login", destination: "Login")
        storage.updateScreenFlow(source: "Home.SignUp", destination: "SignUp")
        storage.fetchAndUpdate(screenFlowProvider: mockScreenFlowProvider)

        //Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: "Home.SignUp")
        let actualOutput = AnyView(SignUp())
        XCTAssertTrue(propertiesAreEqual(expectedOutput, actualOutput))
    }

    // Test correct retrival of the Core Data container
    func testGetStorageProvider() {
        // Given
        let storage = StorageProvider(storeType: .inMemory)
        let mockErrorHandler = MockErrorHandler()
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: storage)

        // When
        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)

        storage.addScreenFlow(source: "Home.SignUp", destination: "SignUp")
        storage.addScreenFlow(source: "Home.Login", destination: "Login")

        let returnedStorage = mockScreenFlowProvider.getStorageProvider()


        //Then
        let expectedOutput = returnedStorage.getAllScreenFlows()
        let actualOutput = storage.getAllScreenFlows()
        XCTAssertEqual(expectedOutput, actualOutput)
    }

    func testErrorResponse() async throws {
        // Given
        let mockSession = MockNetworkSession()
        let service = WebServiceImpl(networkSession: mockSession)

        let mockURL = URL(string: "http://test.com")!
        let mockResponse = HTTPURLResponse(url: mockURL, statusCode: 500, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = jsonData
        mockSession.mockResponse = mockResponse

        do {
        // When
            let _ = try await service.loadUrlData(resource: "http://test.com")
            XCTFail("loadUrlData should have thrown an error for invalid server response")
        } catch {
        // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidServerResponse)
        }
    }

    func testInvalidURL() async {
        // Given
        let mockSession = MockNetworkSession()
        let service = WebServiceImpl(networkSession: mockSession)
        let invalidUrlString = "1"

        do {
        // When
            let _ = try await service.loadUrlData(resource: invalidUrlString)
            XCTFail("loadUrlData should have thrown an error for invalid server response")
        } catch {
        // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidUrl)
        }
    }

    // Tests that data is retrieved from the Core Data container when the application is offline
    @MainActor func testOfflineWorking() async {
        // Given
        let mockErrorHandler = MockErrorHandler()
        let storage = StorageProvider(storeType: .inMemory)
        let mockScreenFlowProvider = ScreenFlowProvider(errorHandle: mockErrorHandler, storageProvider: storage)

        let mockSession = MockNetworkSession()
        let service = WebServiceImpl(networkSession: mockSession)

        let viewModel = FlowMagicViewModel(service: service, screenFlowProvider: mockScreenFlowProvider)

        // When
        // Register Home and Sign Up screens
        mockScreenFlowProvider.registerScreen(screenName: homeScreen, portNames: homeScreenPortNames, view: homeView)
        mockScreenFlowProvider.registerScreen(screenName: signUpScreen, portNames: signUpScrPortNames, view: signUpView)
        mockScreenFlowProvider.registerScreen(screenName: loginScreen, portNames: loginScrPortNames, view: loginView)

        storage.addScreenFlow(source: "Home.SignUp", destination: "SignUp")
        storage.addScreenFlow(source: "Home.Login", destination: "Login")
        storage.updateScreenFlow(source: "Home.SignUp", destination: "SignUp")
        storage.fetchAndUpdate(screenFlowProvider: mockScreenFlowProvider)

        // When
        storage.updateScreenFlow(source: "Home.SignUp", destination: "Login")
        storage.fetchAndUpdate(screenFlowProvider: mockScreenFlowProvider)
        await viewModel.load()

        // Then
        let expectedOutput = mockScreenFlowProvider.getDestinationScreen(portName: "Home.SignUp")
        let actualOutput = AnyView(Login())
        XCTAssertTrue(propertiesAreEqual(expectedOutput, actualOutput))
    }

}
