//
//  StylableView.swift
//

import Foundation

import SwiftUI
import Combine

public struct Stylable: View {

    @EnvironmentObject private var stylist: Stylist
    @Environment(\.currentStylableGroup) private var currentStylableGroup

    private let identifier: StylistIdentifier?

    /// The contained view, wrapped in AnyView. We can't just create this on the fly from `self.contains` (i.e. `AnyView(self.contains)` won't work
    /// because we don't know the type of `self.contains` apart from in the `init` method.
    private let wrappedContains: AnyView

    /// The view to be styled, stored without it's type (i.e. as `Any`)
    private let contains: Any

    // MARK: Initialisation and Creation

    init<T: View>(_ contains: T, identifier: StylistIdentifier?) {
        self.identifier = identifier
        self.wrappedContains = AnyView(contains)
        self.contains = contains
    }

    /// Calling `StylableView(StylableView(<view>))` shouldn't add another layer to the hierarchy. This init method makes sure it doesn't.
    init(_ contains: Stylable, identifier: StylistIdentifier?) {
        self.identifier = identifier
        self.wrappedContains = contains.wrappedContains
        self.contains = contains.contains
    }

    /// If we know we are wrapping `AnyView` we don't need to do lots of logic / wrapping during initialisation.
    init(_ contains: AnyView, identifier: StylistIdentifier?) {
        self.identifier = identifier
        self.wrappedContains = contains
        self.contains = contains
    }

    /// Allows `StylableView` to be used like other views
    public init<T: View>(_ identifier: StylistIdentifier, @ViewBuilder builder: () -> T) {
        self.init(builder(), identifier: identifier)
    }

    // MARK: View methods

    public var body: some View {
        // There's some magic going on in here.

        // We need to pass in a `Stylable` to `self.stylist` so we get methods like `styleText:` etc. However, we then return a tree from the stylist
        // which still contains a `Stylable` instance. We don't want to style that again (we'll loop forever if we do) so we strip the identifier from the
        // Stylable instance so it won't be styled again.

        // There is probably a smarter way to do this (i.e. separate out the Stylable which can be styled, and a Stylable-like view which _has_ been styled.
        // but that's on my todo list. For now, I'm just accepting that we will call this view's body twice.

        // If we don't have an identifier, don't style the view
        guard let identifier = self.identifier else { return self.wrappedContains }

        // Remove the identifier from the Stylable and apply it's styles.
        let unidentifiedStylable = Stylable(self, identifier: nil)
        let actualIdentifier = identifier.within(self.currentStylableGroup)
        return AnyView(self.stylist.style(view: unidentifiedStylable, identifier: actualIdentifier))
    }

    // MARK: Styling methods

    /// Call this, passing in the type of view you are going to style and a method to style it.
    ///
    /// i.e.
    ///
    /// ```
    /// stylable.style(Text.self) { text in
    ///     text.kerning(5)
    /// }
    /// ```
    ///
    /// - parameter type: The type of the view to be passed into the apply block
    /// - parameter apply: The method to apply to the view (if the styled view isn't an instance of `U` then this will not be called)
    public func style<U: View, V: View>(_ type: U.Type, apply: (U) -> V) -> Stylable {
        guard let contains = self.contains as? U else { return self }

        return Stylable(apply(contains), identifier: nil)
    }

    /// A variant of style(type:apply:) where the type is inferred from the signature of the `apply` parameter.
    ///
    /// i.e.
    /// ```
    /// stylist.style { (text: Text) in
    ///     text.kerning(5)
    /// }
    /// ```
    ///
    /// - parameter apply: The method to apply to the view (if the styled view isn't an instance of `U` then this will not be called)
    public func style<U: View, V: View>(apply: (U) -> V) -> Stylable {
        return self.style(U.self, apply: apply)
    }

    /// Wrapper around `style(apply:)` to make it nicer at the call site.
    ///
    /// i.e.
    /// ```
    /// stylist.styleText { text in ... }
    /// ```
    /// is exactly the same as
    /// ```
    /// stylist.style { (text: Text) in ... }
    /// ```
    ///
    /// - parameter apply: The method to apply to the `Text` (if the styled view isn't an instance of `Text` then this will not be called)
    public func styleText(_ apply: (Text) -> (Text)) -> Stylable {
        return self.style(apply: apply)
    }
}
