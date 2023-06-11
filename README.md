# Flow Magic SDK

Welcome to the Flow Magic SDK! A powerful, yet simple, screen flow management tool for SwiftUI applications. This SDK simplifies navigation between views, allowing developers to focus more on creating features and less on managing transitions.

## Core Features

- **Screen Registration:** Define your screens and register them with Flow Magic.
- **Connection Mapping:** Specify the navigation flow between your screens.
- **Simplified Navigation:** Easily navigate from one view to another with our `getDestinationScreen()` method.

## Getting Started

To begin, you'll need to incorporate Flow Magic into your project. This can be done using Swift Package Manager with the SDK's GitHub URL.

Once you've added Flow Magic to your project, your journey begins in the `FlowMagicApp.swift` file. Here, you'll register your screens and define their connections. 

Here is a template to get you started:

```swift
@main
struct FlowMagicApp: App {
    init() {
        // Register your screens
        ScreenFlowProvider.shared.registerScreen(screenName: "Home", portNames: ["SignUp", "Login", "RandomPage"], view: Home())
        ScreenFlowProvider.shared.registerScreen(screenName: "Login", portNames: [], view: Login())
        ScreenFlowProvider.shared.registerScreen(screenName: "SignUp", portNames: [], view: SignUp())
        ScreenFlowProvider.shared.registerScreen(screenName: "RandomPage", portNames: [], view: RandomPage())

        // Define your connections
        ScreenFlowProvider.shared.addConnection(fromPort: "Home.SignUp", toScreen: "SignUp")
        ScreenFlowProvider.shared.addConnection(fromPort: "Home.Login", toScreen: "Login")
        ScreenFlowProvider.shared.addConnection(fromPort: "Home.RandomPage", toScreen: "RandomPage")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

With screens registered and connections defined, navigate through your views using the `.getDestinationScreen()` method. This is a replacement for the standard `navigationLink()` method. For example:

```swift
ScreenFlowProvider.shared.getDestinationScreen(portName: "Home.SignUp")
```

## Action Ports

An integral part of Flow Magic is the concept of action ports. Action ports are defined when you register a screen, and they specify the possible navigations from the current screen. For instance, the "Screen A" screen may have action ports like "Login", and "SignUp", indicating that these are possible navigation destinations from "Screen A".

<img width="481" alt="image" src="https://github.com/KedarDhere/FlowMagic-SDK/assets/97313818/c3e3d494-494f-4c7e-aefe-0e88df1c2fc1">

## Requirements

- iOS 14.0 or later
- SwiftUI

## Installation

Add Flow Magic SDK to your project using Swift Package Manager with the SDK's GitHub URL.

## Support

Found a bug or have a feature request? We would love to hear about it. Please submit an issue on the GitHub repository.
