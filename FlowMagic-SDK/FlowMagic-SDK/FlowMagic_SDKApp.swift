//
//  FlowMagicApp.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import SwiftUI

@main
struct FlowMagicApp: App {
    init() {
        // Register screens
        ScreenFlowProvider.shared
                          .registerScreen( screenName: "Home",
                                           portNames: ["SignUp", "Login", "RandomPage"],
                                           view: Home())
        ScreenFlowProvider.shared.registerScreen(screenName: "Login", portNames: [], view: Login())
        ScreenFlowProvider.shared.registerScreen(screenName: "SignUp", portNames: [], view: SignUp())
        ScreenFlowProvider.shared.registerScreen(screenName: "RandomPage", portNames: [], view: RandomPage())

        // Add Connections
        ScreenFlowProvider.shared.addConnection(fromPort: "Home", toScreen: "SignUp")
        ScreenFlowProvider.shared.addConnection(fromPort: "Home", toScreen: "Login")
        ScreenFlowProvider.shared.addConnection(fromPort: "Home", toScreen: "RandomPage")
    }
    var body: some Scene {
        WindowGroup {
            Home()
        }
    }
}
