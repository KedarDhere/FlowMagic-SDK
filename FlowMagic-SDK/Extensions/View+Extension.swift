//
//  View+Extension.swift
//  FlowMagic
//
//  Created by Kedar Dhere on 2/25/23.
//

import Foundation
import SwiftUI

extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }
}
