//
//  Stylist.swift
//

import Foundation

import SwiftUI
import UIKit

public struct Style {
    public typealias StyleApplyFunction = (Stylable) -> AnyView

    let identifier: ThemedStylistIdentifier
    let apply: StyleApplyFunction

    /// A value to pass into the apply: parameter when creating a `Style`, making it clear that no style is being applied to an identifier.
    public static let unstyled: StyleApplyFunction = { AnyView.lift($0) }

    public init<T: View>(_ identifier: ThemedStylistIdentifier, apply: @escaping (Stylable) -> T) {
        self.identifier = identifier
        self.apply = { AnyView.lift(apply($0)) }
    }
}

public class Stylist: ObservableObject {

    // All the styles this stylist knows about, in order of specificity (more specific -> more general)
    @Published private var styles: [Style] {
        didSet {
            self.scoredStyleMatchCache = [:]
        }
    }
    @Published public var currentTheme: Theme? {
        didSet {
            self.scoredStyleMatchCache = [:]
        }
    }

    private var scoredStyleMatchCache: [StylistIdentifier: Style] = [:]

    let matcher = StylistIdentifierMatcher()

    private var defaultStyle: Style?

    public init() {
        self.styles = []
    }

    public func setDefaultStyle<V: View>(style: @escaping (Stylable) -> V) {
        self.defaultStyle = Style(.unique, apply: style)
    }

    /// Convenience method to easily create and add a single style.
    public func addStyle<V: View>(identifier: ThemedStylistIdentifier, style: @escaping (Stylable) -> V) {
        self.addStyles([Style(identifier, apply: style)])
    }

    /// Add multiple styles, publishing a single notification when all the styles have been stored.
    public func addStyles(_ newStyles: [StyleContainer]) {
        guard self !== Self.unstyled else {
            fatalError("You can't add a style to Stylist.unstyled")
        }

        var styles = self.styles

        /// Convert the style container to a flat array of all the individual styles.
        let newStyles = newStyles.flatMap { $0.styles }

        // Remove existing styles
        for style in newStyles {
            if let existingIndex = self.styles.firstIndex(where: { $0.identifier == style.identifier }) {
                styles.remove(at: existingIndex)
            }
        }

        // Publish our changes
        self.styles.append(contentsOf: newStyles)
    }

    /// Add multiple styles, publishing a single notification when all the styles have been stored.
    public func addStyles(@StyleBuilder styles: () -> [Style]) {
        self.addStyles(styles())
    }

    func style(view: Stylable, identifier: StylistIdentifier) -> some View {

        let bestMatch = self.getBestMatch(identifier: identifier)

        if let style = bestMatch {
            // Apply the style
            Logger.default.log("Applying", style.identifier.description, "to", identifier, level: .debug)
            return AnyView(style.apply(view))
        } else if let style = self.defaultStyle {
            // Apply the default style
            Logger.default.log("Applying default style", "to", identifier, level: .debug)
            return AnyView(style.apply(view))
        } else {
            // There is no style to apply
            Logger.default.log("No matching style found for", identifier, level: .error)
            return AnyView(view)
        }
    }

    private func getBestMatch(identifier: StylistIdentifier) -> Style? {

        if let bestMatch = self.scoredStyleMatchCache[identifier] {
            return bestMatch
        }

        // Apply the best matching style
        let scored = self.styles
            .filter { $0.identifier.theme == nil || $0.identifier.theme == self.currentTheme }
            .compactMap { (candidate: Style) -> (score: Int, style: Style)? in
                let score = self.matcher.match(specific: identifier, general: candidate.identifier)
                guard score > 0 else { return nil }
                return (score, candidate)
            }

        // The best match is the highest scoring match
        let bestMatch = scored
            .max { $0.score < $1.score }?
            .style

        self.scoredStyleMatchCache[identifier] = bestMatch

        return bestMatch
    }
}

extension Stylist {

    /// A `Stylist` which will not apply any styles.
    public static let unstyled = Stylist()
}

extension Stylist: CustomStringConvertible {

    public var description: String {
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        return "Stylist(\(opaque))"
    }
}

extension AnyView {

    /// Turns a view into AnyView, unless view is already an AnyView in which case it just returns view
    static func lift<T: View>(_ view: T) -> AnyView {
        return AnyView(view)
    }

    /// If you're lifting an AnyView, you don't need to.
    static func lift(_ view: AnyView) -> AnyView { view }
}

/// Defines a type which can provide multiple styles at once.
public protocol StyleContainer {

    /// All the styles contained within this container.
    var styles: [Style] { get }
}

/// A `Style` can be considered a container, containing only one style (itself).
extension Style: StyleContainer {

    public var styles: [Style] { [self] }
}

/// Function builder used to allow function-builder-style syntax to the addStyles(_:) method on Stylist
@resultBuilder
public struct StyleBuilder {

    public static func buildBlock(_ styles: StyleContainer...) -> [Style] {
        styles.flatMap { $0.styles }
    }
}
