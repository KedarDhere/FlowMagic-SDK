//
//  screenFlowModel.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import Foundation
import SwiftUI

public struct ScreenInfoModel: Codable {
    let screenName: String
    let portName: String
    let destinationView: String
}

public struct ApplicationScreenFlowModel: Codable {
    let screenName: String
    let portName: String
    let destinationView: String
}

public struct ScreenFlowModel: Codable {
    let applicationId: String
    let applicationScreenFlow: [ApplicationScreenFlowModel]
}
