//
//  WithStyleIdentifier.swift
//  Pods-StylableSwiftUI_Example
//
//  Created by Sam Dean on 27/08/2020.
//

import Foundation

import SwiftUI

/// Extracts out the current stylist identifier to pass into the block to create this `View`'s contents.
///
/// This struct will take the current `StylableGroup` into account when calling it's creation block.
///
/// ```
/// var body: some View {
///   WithStylistIdentifier(token: "title") { identifier in
///     ... create views using
///         the identifier ...
///   }
/// }
/// ```
///
/// Multiple tokens can be passed in to save deeply nesting if multiple identifiers are needed.
///
/// ```
/// var body: some View {
///   WithStylistIdentifier(tokens: "title", "icon") { titleIdentifier, iconIdentifier in
///     ... create views using
///         the identifiers ...
///   }
/// }
/// ```
///
public struct WithStylistIdentifier<Content: View>: View {

    @Environment(\.currentStylableGroup) private var currentStylableGroup

    private let identifiers: [StylistIdentifier]

    private let contents: ([StylistIdentifier]) -> Content

    init(tokens: [String], contents: @escaping ([StylistIdentifier]) -> Content) {
        self.identifiers = tokens.map { StylistIdentifier($0) }
        self.contents = contents
    }

    public init(stylistIdentifiers: [StylistIdentifier], contents: @escaping ([StylistIdentifier]) -> Content) {
        self.identifiers = stylistIdentifiers
        self.contents = contents
    }

    public var body: some View {
        // Create the identifier from the current stylist group and our tokens
        let path = self.currentStylableGroup ?? .empty
        let identifiers = self.identifiers.map { $0.within(path) }

        // Use it to create the body
        return self.contents(identifiers)
    }
}

public extension WithStylistIdentifier {

    init(string: String,
                @ViewBuilder contents: @escaping (StylistIdentifier) -> Content) {
        self.identifiers = [ StylistIdentifier(string) ]
        self.contents = { contents($0[0]) }
    }

    init(strings token1: String, _ token2: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ StylistIdentifier(token1), StylistIdentifier(token2) ]
        self.contents = { contents($0[0], $0[1]) }
    }

    init(strings token1: String, _ token2: String, _ token3: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ StylistIdentifier(token1), StylistIdentifier(token2), StylistIdentifier(token3) ]
        self.contents = { contents($0[0], $0[1], $0[2]) }
    }

    init(strings token1: String, _ token2: String, _ token3: String, _ token4: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ StylistIdentifier(token1), StylistIdentifier(token2), StylistIdentifier(token3), StylistIdentifier(token4) ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3]) }
    }

    init(strings token1: String, _ token2: String, _ token3: String, _ token4: String, _ token5: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ StylistIdentifier(token1), StylistIdentifier(token2), StylistIdentifier(token3), StylistIdentifier(token4), StylistIdentifier(token5) ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3], $0[4]) }
    }
}

public extension WithStylistIdentifier {

    init(identifier: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier) -> Content) {
        self.identifiers = [ identifier ]
        self.contents = { contents($0[0]) }
    }

    init(identifiers identifier1: StylistIdentifier, _ identifier2: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ identifier1, identifier2 ]
        self.contents = { contents($0[0], $0[1]) }
    }

    init(identifiers identifier1: StylistIdentifier, _ identifier2: StylistIdentifier, _ identifier3: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ identifier1, identifier2, identifier3 ]
        self.contents = { contents($0[0], $0[1], $0[2]) }
    }

    init(identifiers identifier1: StylistIdentifier, _ identifier2: StylistIdentifier, _ identifier3: StylistIdentifier, _ identifier4: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ identifier1, identifier2, identifier3, identifier4 ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3]) }
    }

    init(identifiers identifier1: StylistIdentifier, _ identifier2: StylistIdentifier, _ identifier3: StylistIdentifier, _ identifier4: StylistIdentifier, _ identifier5: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.identifiers = [ identifier1, identifier2, identifier3, identifier4, identifier5 ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3], $0[4]) }
    }
}

