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

protocol WebService {
    func loadUrlData(resource: String) async throws -> ScreenFlowModel
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

extension URLResponse {
    var isSuccessful: Bool {
        guard let httpResponse = self as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
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

class WebServiceImpl: WebService {
    func loadUrlData(resource: String) async throws -> ScreenFlowModel {

        guard let url = URL(string: resource) else {
            throw NetworkError.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        let screenData = try JSONDecoder().decode(ScreenFlowModel.self, from: data)
        print(screenData)
        return screenData
    }
}
