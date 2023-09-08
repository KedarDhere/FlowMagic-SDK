//
//  FlowMagic_SDKTests.swift
//  FlowMagic-SDKTests
//
//  Created by Kedar Dhere on 3/5/23.
//

import XCTest
@testable import FlowMagic_SDK

final class EndpointsTests: XCTestCase {
    func testEndpoints() {
        let baseUrl = Constants.Urls.baseUrl
        let applicationScreenFlowEndpoint = Constants.Urls.applicationScreenFlow

        XCTAssertEqual(baseUrl, "http://localhost:8000/",
                       "Base Url should be 'http://localhost:8000/'")
        XCTAssertEqual(applicationScreenFlowEndpoint,
                    "\(baseUrl)applications/66ceb688-a2b3-11ed-a8fc-0242ac120002/screenFlow" )
    }
}
