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

public protocol WebService {
    func loadUrlData(resource: String) async throws -> ScreenFlowModel
}

public class WebServiceImpl: WebService {
    private let networkSession: NetworkSession

    public init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
    }

    public func loadUrlData(resource: String) async throws -> ScreenFlowModel {
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
