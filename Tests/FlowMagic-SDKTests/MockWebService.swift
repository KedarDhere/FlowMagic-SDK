//
//  MockWebService.swift
//  FlowMagic-SDKTests
//
//  Created by Kedar Dhere on 9/13/23.
//

import Foundation
@testable import FlowMagic_SDK

class MockWebService: WebService {
    func loadUrlData(resource: String) async throws -> ScreenFlowModel {
        let mockScreenFlowData = """
        {
            "applicationId": "66ceb688a2b311eda8fc0242ac120002",
            "applicationScreenFlow": [
              {
                "screenName": "Login",
                "portName": "Home.Login",
                "destinationView": "SignUp"
              },
              {
                "screenName": "SignUp",
                "portName": "Home.SignUp",
                "destinationView": "Login"
              }
            ]
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let screenFlowData = try decoder.decode(ScreenFlowModel.self, from: mockScreenFlowData)
        return screenFlowData
    }
}
