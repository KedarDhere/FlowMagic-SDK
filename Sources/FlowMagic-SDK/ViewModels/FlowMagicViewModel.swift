//
//  flowMagicViewModel.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/25/23.
//

import Foundation
import SwiftUI

@MainActor
public class FlowMagicViewModel: ObservableObject {
    // MARK: Properties
    private var service: WebService
    let screenFlowProvider: ScreenFlowProviding
    
    @Published var destinationViewsFromPorts: [String: any View] = [:]

    // MARK: Initialization
  
    public init(service: WebService, screenFlowProvider: ScreenFlowProviding) {
        self.service = service
        self.screenFlowProvider = screenFlowProvider
    }

    // MARK: Methods

    /// Make the network call and fetch the latest screen data from the server
    public func load() async {
        do {
            let screenFlowModel = try await service.loadUrlData(resource: Constants.Urls.applicationScreenFlow)
            print(screenFlowModel)
            renderDestinationView(screenFlowModel: screenFlowModel)
            destinationViewsFromPorts = screenFlowProvider.getDestinationViewsFromPorts()
        } catch {
            screenFlowProvider.getStorageProvider().fetchAndUpdate(screenFlowProvider: screenFlowProvider)
            destinationViewsFromPorts = screenFlowProvider.getDestinationViewsFromPorts()
            print(error)
        }

    }

    public func renderDestinationView(screenFlowModel: ScreenFlowModel) {
        var destinationView: AnyView = ProgressView().toAnyView()
        let screens = screenFlowProvider.getScreens()
        for screenInfo in screenFlowModel.screenFlow {
            let screen = screens[screenInfo.destinationView]
            destinationView = screen!.0
            screenFlowProvider.updateDestinationViewsFromPorts(
                portName: screenInfo.portName, destinationView: destinationView, destinationScreenName: screenInfo.destinationView )
        }
    }
}
