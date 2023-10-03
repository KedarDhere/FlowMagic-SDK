//
//  URLResponse+Extension.swift
//  FlowMagic-SDK
//
//  Created by Kedar Dhere on 9/13/23.
//

import Foundation

extension URLResponse {
    var isSuccessful: Bool {
        guard let httpResponse = self as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
    }
}
