//
//  StylableImage.swift
//

import Foundation
import SwiftUI
import UIKit

public struct StylableImage: View {

    public static let defaultSeparator = "_"

    private let identifier: StylistIdentifier
    private let factory: (StylistIdentifier, Theme?) -> Image

    @EnvironmentObject private var stylist: Stylist
    @Environment(\.currentStylableGroup) var currentStylableGroup

    private init(_ identifier: StylistIdentifier, factory: @escaping (StylistIdentifier, Theme?) -> Image) {
        self.identifier = identifier
        self.factory = factory
    }

    public init(_ identifier: StylistIdentifier, separator: String = defaultSeparator, bundle: Bundle? = nil, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.identifier = identifier
        self.factory = { identifier, theme in Image(identifier: identifier,
                                                    theme: theme,
                                                    separator: separator,
                                                    bundle: bundle,
                                                    compatibleWith: traitCollection)
        }
    }

    public var body: some View {
        self.factory(StylistIdentifier(token: self.identifier.token,
                                       path: self.identifier.path.within(self.currentStylableGroup)), self.stylist.currentTheme)
    }

    // MARK: - Wrapped Image methods

    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0, $1).renderingMode(renderingMode) }
    }

    public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0, $1).resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    public func interpolation(_ interpolation: Image.Interpolation) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0, $1).interpolation(interpolation) }
    }

    public func antialiased(_ isAntialiased: Bool) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0, $1).antialiased(isAntialiased) }
    }
}

extension Image {

    /// Creates an `Image` using the stylist identifier.
    ///
    /// This method attempts the most specific image name first. i.e. `section/element/atom` would try
    /// `section_element_atom` then `*_element_atom` then `section_*_atom`, finally `*_*_atom`.
    ///
    /// - parameter identifier: The `StylistIdentifier` to use when attempting to find/load an image
    /// - parameter theme: _(optional)_ The theme to apply when searching for the image (defaults to `nil`)
    /// - parameter separator: _(optional)_ The character to use when joining the components together to create the resource name (defaults to `_`)
    /// - parameter bundle: _(optional)_ The bundle to search for the image (defaults to the main bundle)
    /// - parameter compatibleWith: _(optional)_ The trait collection to use for the image (defaults to `nil`).
    ///
    init(identifier: StylistIdentifier,
         theme: Theme? = nil,
         separator: String = StylableImage.defaultSeparator,
         bundle: Bundle? = nil,
         compatibleWith traitCollection: UITraitCollection? = nil) {

        // Get the image if it exists
        let image = identifier.uiImage(separator: separator, bundle: bundle, compatibleWith: traitCollection, theme: theme)

        if image == nil {
            Logger.default.log("No image found for \(identifier)", level: .error)
        }

        // Return it, or a dummy image view
        self = image.map { Image(uiImage: $0) } ?? Image(identifier.description)
    }
}

extension StylistIdentifier {

    /// All the possible names for a image based on this identifier
    func potentialImageNames(separator: String = StylableImage.defaultSeparator, theme: Theme? = nil) -> AnySequence<String> {
        let components = Array(self.path.components.reversed())

        let options = VariantSequence(from: components)

        // Append the token to the end - it's always there.
        let optionsWithToken = options
            .lazy
            .flatMap { option -> [[String]] in
                if let theme = theme {
                    return [
                        [theme.name] + option.map { $0.description } + [self.token],
                        option.map { $0.description } + [self.token]
                    ]
                }
                return [ option.map { $0.description } + [self.token] ]
            }

        // Return the sequence, joining the components with the requested separator
        return AnySequence(optionsWithToken.map { $0.joined(separator: separator) })
    }
}

private struct VariantSequence: Sequence, IteratorProtocol {

    /// Save some typing in here.
    typealias Component = StylistIdentifier.Component

    /// The original components used to create the breakdown
    private let components: [Component]

    /// Calculate the maximum possible options to output for this sequence.
    private let maxIndex: Int

    /// The current index into the sequence.
    private var index = 0

    /// This prevents this sequence from outputing duplicate values.
    ///
    /// This is pretty inefficient - it would be better to work out how to not calculate them in the first place,
    /// but to keep the code 'simple' it's easier to use a bitmask and just drop masks which produce a component with
    /// a variant but not value - which is impossible in NDS.
    private var deduplicate = Set<[Component]>()

    init(from components: [Component]) {
        self.components = Array(components)
        self.maxIndex = Int(pow(2.0, Double(components.count)*2))
    }

    mutating func next() -> [Component]? {

        // There's a bit of a while here - we don't want to return duplicate values from the sequence.
        // Originally, I recursed but Swift won't do tail-optimisation and the stack suffered :)

        var result: [Component]?
        while result == nil {

            // If we hit the end of the sequence, just bail.
            guard self.index < self.maxIndex else { return nil }

            result = self.components
                .enumerated()
                .compactMap { (index, component) -> Component? in

                    // Each component can have either the value, the variant, or neither masked out
                    let valueMask = 1 << (index*2+1)

                    // If we are masking out the value, then we don't care about the variant so just return nil
                    if self.index & valueMask != 0 {
                        return nil
                    }

                    let variantMask = 1 << (index*2)

                    // If we are masking out the variant, return a new component
                    if self.index & variantMask != 0 {
                        return Component(value: component.value, variant: nil)
                    }

                    // If we aren't masking anything in this component, just return it as-is
                    return component
            }

            self.index += 1

            // If we have a result, is it a duplicate?
            if let foundResult = result {
                if deduplicate.contains(foundResult) {
                    result = nil
                } else {
                    deduplicate.insert(foundResult)
                }
            }
        }

        return result
    }
}

// MARK: - UIImage

public extension Stylist {
    func uiImage(for identifier: StylistIdentifier,
                 separator: String = StylableImage.defaultSeparator,
                 bundle: Bundle? = nil,
                 compatibleWith traits: UITraitCollection? = nil) -> UIImage? {
        return identifier.uiImage(separator: separator, bundle: bundle, compatibleWith: traits, theme: self.currentTheme)
    }
}

extension StylistIdentifier {
    func uiImage(separator: String = StylableImage.defaultSeparator,
                 bundle: Bundle? = nil,
                 compatibleWith traits: UITraitCollection? = nil,
                 theme: Theme? = nil) -> UIImage? {
        self.potentialImageNames(separator: separator, theme: theme)
            .lazy
            .compactMap { UIImage(named: $0, in: bundle, compatibleWith: traits) }
            .first
    }
}
