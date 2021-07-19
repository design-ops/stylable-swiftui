//
//  Stylist+Theme.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 16/07/2021.
//

import Foundation

public struct Theme: Equatable, Hashable {
    public let name: String

    static let identifierPrefix = "@"

    var value: String {
        return "\(Self.identifierPrefix)\(name)"
    }

    public init(name: String) {
        if name.starts(with: "@") {
            self.name = String(name.dropFirst())
        } else {
            self.name = name
        }
    }
}
