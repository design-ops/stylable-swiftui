//
//  Stylist+Theme.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 16/07/2021.
//

import Foundation

public struct Theme: Equatable, Hashable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
