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
/// # Creating Identifiers
///
/// Identifiers have a construct like `StylistIdentifier("button/close")`, but also implement `ExpressibleByStringLiteral`, so passing a string literal into
/// a method expecting a StylistIdentifier is (usually) far less code.
///
/// Identifiers can be combined using `within(_:)` i.e. `"close".within("button")` would return the identifier "button/close".
///
/// # Variant
///
/// Identifiers can also contain the idea of variant i.e.
///
/// `button[selected]/close` is a valid identifier. `button/close` will match this identifier, as will `*/close`.
///
public struct StylistIdentifier: Equatable, Hashable {

    /// Given the identifier `header/searchBar/title` then `title` is the token
    let token: String

    /// Given the identifier `header/searchBar/title` then the components are `[ "header", "searchBar" ]`
    let path: Path
}

extension StylistIdentifier: LosslessStringConvertible {

    /// Create an instance of StylistIdentifier from a String, specifying the separator to use
    ///
    /// - note: Given this method cannot throw or fail, it's possible to create insane identifiers i.e. an empty string. You have been warned.
    ///
    /// - parameter description: The string to parse into an identifier
    public init(_ description: String) {
        let split = description.split(separator: "/").map(String.init)

        let token = split.last ?? ""

        let path = Path(split.dropLast().joined(separator: "/"))

        self.init(token: token, path: path)
    }

    public var description: String {
        let pathDescription = self.path.description

        guard !pathDescription.isEmpty else {
            return self.token
        }

        return pathDescription + "/" + self.token
    }
}

extension StylistIdentifier: ExpressibleByStringLiteral {

    /// Create an instance of StylistIdentifier from a String, using the default separator (`"/"`)
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - Component

extension StylistIdentifier {

    public struct Path: CustomStringConvertible, LosslessStringConvertible, ExpressibleByStringLiteral, Equatable, Hashable {

        let components: [Component]

        init(components: [Component]) {
            self.components = components
        }

        public init(_ value: String) {
            self.components = value
                .split(separator: "/")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .reversed()
                .map { Component($0) }
        }

        public init(stringLiteral value: String) {
            self.init(value)
        }

        public var description: String {
            self.components.reversed().map(String.init).joined(separator: "/")
        }

        var isEmpty: Bool { self.components.isEmpty }

        func component(at index: Int) -> Component? {
            guard index >= 0 && index < self.components.count else { return nil }
            return self.components[index]
        }

        func within(_ path: Path?) -> Path {
            guard let path = path, !path.isEmpty else { return self }

            var components = self.components
            components.append(contentsOf: path.components)
            return Path(components: components)
        }

        // A path with no components.
        static let empty = Path(components: [])
    }

    struct Component: CustomStringConvertible, Equatable, Hashable {
        let value: String
        let variant: String?

        init(value: String, variant: String?) {
            self.value = value
            self.variant = variant
        }

        init(_ string: String) {
            // Split on [
            //  lhs: store as value
            //  rhs: trim trailing ] and store as variant

            let split = string.split(separator: "[", maxSplits: 1, omittingEmptySubsequences: true)

            // Store the value
            self.value = split.first.map(String.init) ?? ""

            // Get, validate, and store the variant (or just let it be `nil`)
            guard
                let variant = split.second.map(String.init).map({ $0.hasSuffix("]") ? String($0.dropLast()) : $0 }),
                !variant.isEmpty else {
                    self.variant = nil
                    return
            }
            self.variant = variant
        }

        var description: String {
            self.value + (self.variant.map { "[" + $0 + "]" } ?? "")
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

    /// Create an identifier representing `self` inside `path`
    ///
    /// i.e. `"close".within("button") == 'button/close'`
    ///
    public func within(_ path: Path?) -> StylistIdentifier {
        StylistIdentifier(token: self.token, path: self.path.within(path))
    }
}

// MARK: - Some helpers

private extension RandomAccessCollection {

    /// Helper property - exactly the same as `first` but returns the second element, if it exists.
    var second: Element? {
        self.count > 1 ? self[self.index(self.startIndex, offsetBy: 1)] : nil
    }
}
