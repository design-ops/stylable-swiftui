//
//  UIKitStyleContainer.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 03/09/2020.
//

import Foundation

public final class UIKitStyleContainer {
    private var registeredProperties: [StylistIdentifier: [StylistProperty]]
    private let stylist: Stylist

    public init(stylist: Stylist) {
        self.registeredProperties = [:]
        self.stylist = stylist
    }
}

public extension UIKitStyleContainer {
    func addProperty(identifier: StylistIdentifier, properties: () -> [StylistProperty]) {
        self.registeredProperties[identifier] = properties()
    }
}

// MARK: - Properties
public extension UIKitStyleContainer {

    private func properties(for identifier: StylistIdentifier) -> [StylistProperty] {
        // Grab the best matching property
        let scored = self.registeredProperties
            .compactMap { (key: StylistIdentifier, value: [StylistProperty]) -> (score: Int, properties: [StylistProperty])? in
                let score = self.stylist.matcher.match(specific: identifier, general: key)
                guard score > 0 else { return nil }
                return (score, value)
            }

        // The best match is the highest scoring match
        return scored
            .max { $0.score < $1.score }?
            .properties ?? []
    }

    func backgroundColor(for identifier: StylistIdentifier) -> UIColor? {
        self.properties(for: identifier)
            .firstBackgroundColor()
    }

    func textColor(for identifier: StylistIdentifier) -> UIColor? {
        self.properties(for: identifier)
            .firstTextColor()
    }

    func font(for identifier: StylistIdentifier) -> UIFont? {
        self.properties(for: identifier)
            .firstFont()
    }

    func kerning(for identifier: StylistIdentifier) -> Double? {
        self.properties(for: identifier)
            .firstKerning()
    }
}
