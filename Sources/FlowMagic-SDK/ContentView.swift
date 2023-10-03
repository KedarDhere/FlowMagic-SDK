//
//  ContentView.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import SwiftUI

struct Home: View {

    @StateObject private var viewModel = FlowMagicViewModel(service: WebServiceImpl(), screenFlowProvider: ScreenFlowProvider.shared)
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink {
                    AnyView(ScreenFlowProvider.shared.getDestinationScreen(portName: "Home.SignUp"))
                } label: {
                    Text("SignUp")
                }

                NavigationLink {
                    AnyView(ScreenFlowProvider.shared.getDestinationScreen(portName: "Home.Login"))
                } label: {
                    Text("Login")
                }

                NavigationLink {
                    AnyView(ScreenFlowProvider.shared.getDestinationScreen(portName: "Home.RandomPage"))
                } label: {
                    Text("Random Page")
                }
            }.task {
                await viewModel.load()
            }
        }
    }
}

struct Login: View {
    var body: some View {
        Text("Login Page")
    }
}

struct SignUp: View {
    var body: some View {
        Text("Sign Up")
    }
}

struct RandomPage: View {
    var body: some View {
        Text("Random Page")
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
