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

    func textAttributes(for identifier: StylistIdentifier) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        if let textColor = self.textColor(for: identifier) {
            attributes[.foregroundColor] = textColor
        }
        if let font = self.font(for: identifier) {
            let descriptor = self.getFontDescriptor(for: font, identifier: identifier)
            attributes[.font] = UIFont(descriptor: descriptor, size: font.pointSize)
        }
        if let kerning = self.kerning(for: identifier) {
            attributes[.kern] = kerning
        }
        return attributes
    }

    private func getFontDescriptor(for font: UIFont, identifier: StylistIdentifier) -> UIFontDescriptor {
        let descriptor = font.fontDescriptor
        guard let textCase = self.properties(for: identifier).firstTextCase() else {
            return descriptor
        }

        switch textCase {
        case .lowercase:
            let features = [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kUpperCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kDefaultUpperCaseSelector
                ],
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kDefaultLowerCaseSelector
                ]
            ]
            return descriptor.addingAttributes([.featureSettings: features])
        case .uppercase:
            let features = [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kAllCapsSelector
                ],
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kUpperCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kAllCapsSelector
                ]
            ]
            return descriptor.addingAttributes([.featureSettings: features])
        case .none:
            return descriptor
        }
    }

    private func backgroundColor(for identifier: StylistIdentifier) -> UIColor? {
        self.properties(for: identifier)
            .firstBackgroundColor()
    }

    private func textColor(for identifier: StylistIdentifier) -> UIColor? {
        self.properties(for: identifier)
            .firstTextColor()
    }

    private func font(for identifier: StylistIdentifier) -> UIFont? {
        self.properties(for: identifier)
            .firstFont()
    }

    private func kerning(for identifier: StylistIdentifier) -> Double? {
        self.properties(for: identifier)
            .firstKerning()
    }
}
