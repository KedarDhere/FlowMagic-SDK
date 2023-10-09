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
    var coreDataViewModel: CoreDataViewModelProtocol

    @Published var destinationViewsFromPorts: [String: any View] = [:]

    // MARK: Initialization
  
    public init(service: WebService, screenFlowProvider: ScreenFlowProviding, coreDataViewModel: CoreDataViewModelProtocol ) {
        self.service = service
        self.screenFlowProvider = screenFlowProvider
        self.coreDataViewModel = coreDataViewModel
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
            print(error)
        }

    }

    public func renderDestinationView(screenFlowModel: ScreenFlowModel) {
        var destinationView: AnyView = ProgressView().toAnyView()
        let screens = screenFlowProvider.getScreens()
        for screenInfo in screenFlowModel.applicationScreenFlow {
            let screen = screens[screenInfo.destinationView]
            destinationView = screen!.0
            screenFlowProvider.updateDestinationViewsFromPorts(
                portName: screenInfo.portName, destinationScreen: screenInfo.destinationView, destinationView: destinationView)
        }
    }
}
