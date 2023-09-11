//
//  Webservice.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/23/23.
//

import Foundation

enum NetworkError: Error {
    case invalidUrl
    case invalidServerResponse
}

private extension URLResponse {
    var isSuccessful: Bool {
        guard let httpResponse = self as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
    }
}

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

protocol WebService {
    func loadUrlData(resource: String) async throws -> ScreenFlowModel
}

class WebServiceImpl: WebService {
    private let networkSession: NetworkSession

    init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
    }

    func loadUrlData(resource: String) async throws -> ScreenFlowModel {
        guard let url = URL(string: resource) else {
            throw NetworkError.invalidUrl
        }

        let (data, response) = try await networkSession.loadData(from: url)

        if !response.isSuccessful {
            throw NetworkError.invalidServerResponse
        }

        let screenData = try JSONDecoder().decode(ScreenFlowModel.self, from: data)

        return screenData
    }
}
