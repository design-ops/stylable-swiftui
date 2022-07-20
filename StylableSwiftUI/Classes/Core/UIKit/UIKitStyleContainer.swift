//
//  UIKitStyleContainer.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 03/09/2020.
//

import Foundation

public final class UIKitStyleContainer {
    private var registeredProperties: [ThemedStylistIdentifier: [StylistProperty]]
    private let stylist: Stylist

    public init(stylist: Stylist) {
        self.registeredProperties = [:]
        self.stylist = stylist
    }
}

public extension UIKitStyleContainer {
    func addProperty(identifier: ThemedStylistIdentifier, properties: () -> [StylistProperty]) {
        self.registeredProperties[identifier] = properties()
    }
}

// MARK: - Properties
public extension UIKitStyleContainer {

    private func properties(for identifier: StylistIdentifier) -> [StylistProperty] {
        // Grab the best matching property
        let scored = self.registeredProperties
            .filter { $0.key.theme == nil || $0.key.theme == self.stylist.currentTheme }
            .compactMap { (key: ThemedStylistIdentifier, value: [StylistProperty]) -> (score: Int, properties: [StylistProperty])? in
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

    func textCase(for identifier: StylistIdentifier) -> TextCase? {
        self.properties(for: identifier)
            .firstTextCase()
    }
}

// MARK: UIImage

public extension UIKitStyleContainer {
    func uiImage(for identifier: StylistIdentifier,
                 separator: String = StylableImage.defaultSeparator,
                 bundle: Bundle? = nil,
                 compatibleWith traits: UITraitCollection? = nil) -> UIImage? {
        self.stylist.uiImage(for: identifier, separator: separator, bundle: bundle, compatibleWith: traits)
    }
}
