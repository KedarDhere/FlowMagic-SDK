//
//  NetworkSession.swift
//  FlowMagic-SDK
//
//  Created by Kedar Dhere on 9/13/23.
//

import Foundation

protocol NetworkSession {
    func loadData(from url: URL) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: NetworkSession {
    func loadData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await self.data(from: url)
        if let httpResponse = response as? HTTPURLResponse {
            return (data, httpResponse)
        } else {
            throw NetworkError.invalidServerResponse
        }

    }
}

class MockNetworkSession: NetworkSession {
    var mockData: Data?
    var mockResponse: HTTPURLResponse?
    var mockError: Error?

    func loadData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        if let error = mockError {
            throw error
        }
        guard let data = mockData, let response = mockResponse else {
            throw NetworkError.invalidServerResponse
        }
        return (data, response)
    }
}
