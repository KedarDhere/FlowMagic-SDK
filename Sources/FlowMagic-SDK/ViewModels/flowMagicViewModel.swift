//
//  flowMagicViewModel.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/25/23.
//

import Foundation
import SwiftUI

@MainActor
class FlowMagicViewModel: ObservableObject {
    // MARK: Properties
    private var service: Webservice
    @Published var destinationViewsFromPorts: [String: AnyView?] = [:]

    // MARK: Initialization
    init(service: Webservice) {
        self.service = service
    }

    // MARK: Methods

    /// Make the network call and fetch the latest screen data from the server
    func load() async {
        do {
            let screenFlowModel = try await service.loadUrlData(resource: Constants.Urls.applicationScreenFlow)
            print(screenFlowModel)
            screenFlowModel.renderDestinationView(portName: "Home.Login")
            destinationViewsFromPorts = ScreenFlowProvider.shared.getDestinationViewsFromPorts()
        } catch {
            print(error)
        }

    }

}
