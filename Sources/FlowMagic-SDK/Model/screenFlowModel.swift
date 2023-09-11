//
//  screenFlowModel.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import Foundation
import SwiftUI

struct ScreenInfoModel: Decodable {
    let screenName: String
    let portName: String
    let destinationView: String
}

struct ApplicationScreenFlowModel: Decodable {
    let screenName: String
    let portName: String
    let destinationView: String
}

struct ScreenFlowModel: Decodable {
    let applicationId: String
    let applicationScreenFlow: [ApplicationScreenFlowModel]
}
