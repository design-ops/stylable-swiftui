//
//  ThemedStylistIdentifier.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 05/08/2021.
//

import Foundation

public struct ThemedStylistIdentifier: Equatable, Hashable {
    let identifier: StylistIdentifier

    /// The theme for this identifier, if any.
    /// Given the identifier `@dark/header/searchBar/title` then the theme is `@dark`
    /// Given the identifier `header/searchBar/title` then the theme is `nil`
    let theme: Theme?

    var path: StylistIdentifier.Path {
        self.identifier.path
    }

    var token: String {
        self.identifier.token
    }
}

extension ThemedStylistIdentifier: CustomStringConvertible {
    public var description: String {
        guard let theme = self.theme else {
            return self.identifier.description
        }
        return theme.description + "/" + self.identifier.description
    }
}

extension ThemedStylistIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<ThemedStylistIdentifier: \(self.description)>"
    }
}

extension ThemedStylistIdentifier {

    public static var unique: ThemedStylistIdentifier { ThemedStylistIdentifier(identifier: StylistIdentifier(UUID().uuidString), theme: nil) }
}

extension ThemedStylistIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let split = value.split(separator: "/").map(String.init)

        if let first = split.first, first.starts(with: Theme.identifierPrefix) {
            // We have a theme
            self.theme = Theme(name: String(first.dropFirst()))
            self.identifier = StylistIdentifier(split.dropFirst().joined(separator: "/"))
        } else {
            self.theme = nil
            self.identifier = StylistIdentifier(value)
        }
    }
}
