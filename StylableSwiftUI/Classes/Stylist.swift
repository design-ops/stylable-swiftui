//
//  Stylist.swift
//

import Foundation

import SwiftUI
import UIKit

@available(iOS 13.0.0, *)
public struct Style {
    public typealias StyleApplyFunction = (Stylable) -> AnyView

    let identifier: StylistIdentifier
    let apply: StyleApplyFunction

    /// A value to pass into the apply: parameter when creating a `Style`, making it clear that no style is being applied to an identifier.
    public static let unstyled: StyleApplyFunction = { AnyView.lift($0) }

    public init<T: View>(_ identifier: StylistIdentifier, apply: @escaping (Stylable) -> T) {
        self.identifier = identifier
        self.apply = { AnyView.lift(apply($0)) }
    }
}

@available(iOS 13.0.0, *)
public class Stylist: ObservableObject {

    // All the styles this stylist knows about, in order of specificity (more specific -> more general)
    @Published private var styles: [Style]

    public init() {
        self.styles = []
    }

    /// Convenience method to easily create and add a single style.
    public func addStyle<V: View>(identifier: StylistIdentifier, style: @escaping (Stylable) -> V) {
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

        // Append and sort new styles
        styles.append(contentsOf: newStyles)
        styles.sort { $0.identifier < $1.identifier }

        // Publish our changes
        self.styles = styles
    }

    /// Add multiple styles, publishing a single notification when all the styles have been stored.
    public func addStyles(@StyleBuilder styles: () -> [Style]) {
        self.addStyles(styles())
    }

    func style(view: Stylable, identifier: StylistIdentifier) -> some View {

        // Apply the first matching style in our list of styles
        guard let style = self.styles.first(where: { $0.identifier.matches(identifier) }) else {
            Logger.default.log("No matching style found for", identifier, level: .warning)
            return AnyView(view)
        }

        Logger.default.log("Applying", style.identifier.description, "to", identifier, level: .info)
        return AnyView(style.apply(view))
    }
}

@available(iOS 13.0.0, *)
extension Stylist {

    /// A `Stylist` which will not apply any styles.
    public static let unstyled = Stylist()
}

@available(iOS 13.0.0, *)
extension Stylist: CustomStringConvertible {

    public var description: String {
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        return "Stylist(\(opaque))"
    }
}

@available(iOS 13.0.0, *)
extension AnyView {

    /// Turns a view into AnyView, unless view is already an AnyView in which case it just returns view
    static func lift<T: View>(_ view: T) -> AnyView {
        return AnyView(view)
    }

    /// If you're lifting an AnyView, you don't need to.
    static func lift(_ view: AnyView) -> AnyView { view }
}

/// Defines a type which can provide multiple styles at once.
@available(iOS 13.0.0, *)
public protocol StyleContainer {

    /// All the styles contained within this container.
    var styles: [Style] { get }
}

/// A `Style` can be considered a container, containing only one style (itself).
@available(iOS 13.0.0, *)
extension Style: StyleContainer {

    public var styles: [Style] { [self] }
}

/// Function builder used to allow function-builder-style syntax to the addStyles(_:) method on Stylist
@available(iOS 13.0.0, *)
@_functionBuilder
public struct StyleBuilder {

    public static func buildBlock(_ styles: StyleContainer...) -> [Style] {
        styles.flatMap { $0.styles }
    }
}
