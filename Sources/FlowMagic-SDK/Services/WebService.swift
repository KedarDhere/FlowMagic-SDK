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

class Webservice {
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
