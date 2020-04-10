//
//  StylistIdentifier.swift
//

import Foundation

/// Identifies a section which can be styled
///
/// A `StylableIdentifier` is in the form `{component/}/component` i.e. these are all valid identifiers
///
/// ```
/// close
/// button/close
/// customer/button/close
/// ```
///
/// There is no limit to the number of components an identifier can have.
///
/// A StylistIdentifier can also contain wildcards i.e. these are also valid identifiers
///
/// ```
/// */close
/// */button/close
/// customer/*/close
/// ```
///
/// - Creating Identifiers
///
/// Identifiers have a construct like `StylistIdentifier("button/close")`, but also implement `ExpressibleByStringLiteral`, so passing a string literal into
/// a method expecting a StylistIdentifier is (usually) far less code.
///
/// Identifiers can be combined using `within(_:)` i.e. `"close".within("button")` would return the identifier "button/close".
///
/// - Comparing Identifiers
///
/// When comparing identifiers, these are considered equal:
///
/// ```
/// close === close (obviously)
/// close === */close
/// close === */*/close
/// ```
///
/// Identifiers also have a `matches(_:)` method, which will let you know whether an identifier is a more general version of another identifier. i.e.
///
/// ```
/// "close".matches("*") // true
/// "*/close".matches("button/close") // true
/// "button/close".matches("*/close") // false
/// ```
///
/// - State
///
/// Identifiers can also contain the idea of state i.e.
///
/// `button[selected]/close` is a valid identifier. `button/close` will match this identifier, as will `*/close`.
///
public struct StylistIdentifier: Equatable, Hashable {

    // i.e. [identifier, element, section, etc]
    let components: [Component]

    /// A value based on how specific this identifier is.
    ///
    /// The higher the score, the more specific the identifier i.e. the more specific, the less this identifier can
    /// match other identifiers.
    ///
    /// - note: The actual value of this isn't interesting, it's only really useful to compare this to another
    ///         identifier's specificity.
    let specificity: Specificity

    /// Create a completely wildcard `StylistIdentifier` - calling `.matches()` on this will return true for all other `StylistIdentifier`s
    public init() {
        self.components = []
        self.specificity = 0
    }

    public init(components: [String]) {
        self.init(components: components.map { Component($0) })
    }

    init(components: [Component]) {
        self.components = components
        self.specificity = SpecificityCache.shared.specificity(for: components)
    }

    func component(at index: Int) -> Component {
        guard index < self.components.count else { return "*" }
        return self.components[index]
    }

    func withComponent(value: String?, atIndex index: Int) -> Self {
        var components = self.components

        // If the index is greater than the number of components we have, pad our array
        if index >= self.components.count {
            let padding = repeatElement(Component("*"), count: index - self.components.count + 1)
            components.append(contentsOf: padding)
        }

        components[index] = value.map { Component($0) } ?? Component("*")

        return StylistIdentifier(components: components)
    }

    /// An identifier is a wildcard if all of it's components are wildcards (i.e. "*" with no state)
    ///
    /// - note: An identifier with no components (`""`) is also a wildcard.
    var isWildcard: Bool {
        !self.components.contains { !$0.isWildcard }
    }
}

extension StylistIdentifier: LosslessStringConvertible {

    /// Create an instance of StylistIdentifier from a String, specifying the separator to use
    ///
    /// - parameter description: The string to parse into an identifier
    public init(_ description: String) {
        let split = Array(description.split(separator: "/").reversed()).map(String.init)

        self.init(components: split)
    }

    public var description: String {
        self.components
            .reversed()
            .map { $0.description }
            .joined(separator: "/")
    }
}

extension StylistIdentifier: ExpressibleByStringLiteral {

    /// Create an instance of StylistIdentifier from a String, using the default separator (`"/"`)
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension StylistIdentifier: Comparable {

    /// Returns true if `identifier` is a more specific version of `self`
    ///
    /// `*/specific/identifier` matches `very/specific/identifier`
    func matches(_ identifier: StylistIdentifier) -> Bool {
        guard self != identifier else { return true }

        // */*/* is a special case (technically it has no identifier) and it matches _everything_
        guard !self.isWildcard else { return true }

        // Loop through the components, comparing them
        let count = max(self.components.count, identifier.components.count)
        for index in 0..<count {
            let lhs = self.component(at: index)
            let rhs = identifier.component(at: index)

            if !lhs.matches(rhs) { return false }
        }

        return true
    }

    /// `<` here means `lhs` is definitely more specific than `rhs` - `lhs` matches _less_ than `rhs`
    static public func < (lhs: StylistIdentifier, rhs: StylistIdentifier) -> Bool {
        return lhs.specificity > rhs.specificity
    }
}

// MARK: - Component

extension StylistIdentifier {

    struct Component: CustomStringConvertible, Equatable, Hashable {
        let value: String?
        let state: String?

        init(value: String?, state: String?) {
            self.value = value != "*" ? value : nil
            self.state = state
        }

        init(_ string: String) {
            // Split on [
            //  lhs: store as value
            //  rhs: trim trailing ] and store as state

            let split = string.split(separator: "[", maxSplits: 1, omittingEmptySubsequences: true)

            // Store the value
            var value = split.first.map(String.init)
            if value == "*" { value = nil }
            self.value = value

            // Get, validate, and store the state (or just let it be `nil`)
            guard
                let state = split.second.map(String.init).map({ $0.hasSuffix("]") ? String($0.dropLast()) : $0 }),
                !state.isEmpty else {
                    self.state = nil
                    return
            }
            self.state = state
        }

        var description: String {
            (self.value ?? "*") + (self.state.map { "[" + $0 + "]" } ?? "")
        }

        var isWildcard: Bool { self.value == nil && self.state == nil }

        func matches(_ other: Component) -> Bool {
            // Four cases
            //
            // a: value[state]
            // b: value
            // c: *[state]
            // d: *

            // If we are a wildcard component, we match everything
            if self.isWildcard { return true }

            // If we have state and they don't, then we don't match
            if self.state != nil && other.state == nil { return false }

            // if we both have state then they much be equal or we don't match
            if self.state != nil && self.state != other.state { return false }

            // If we have a value but the other is a wildcard then we are more specific i.e. no match
            if self.value != nil && other.value == nil { return false }

            // The values must be the same
            if self.value != other.value { return false }

            return true
        }
    }
}

extension StylistIdentifier.Component: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - Cheeky DSL

extension StylistIdentifier {

    /// Create an identifier representing `self` inside `identifier`
    ///
    /// i.e. `"close".within("button") == 'close/button'`
    ///
    public func within(_ identifier: StylistIdentifier?) -> StylistIdentifier {
        guard let identifier = identifier else { return self }

        var components = self.components
        components.append(contentsOf: identifier.components)
        return StylistIdentifier(components: components)
    }
}

extension String {

    /// Asthetic wrapper around `StylistIdentifier.within(_:)`
    ///
    /// Allows code like `"close".within("button")` to compile and return a valid `StylistIdentifier`
    public func within(_ identifier: StylistIdentifier?) -> StylistIdentifier {
        return StylistIdentifier(self).within(identifier)
    }
}

// MARK: - Some helpers

private extension Collection {

    /// Helper property - exactly the same as `first` but returns the second element, if it exists.
    var second: Element? {
        self.count > 1 ? self[self.index(self.startIndex, offsetBy: 1)] : nil
    }
}
