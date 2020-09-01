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

    private let tokens: [StylistIdentifier]

    private let contents: ([StylistIdentifier]) -> Content

    init(tokens: [String], contents: @escaping ([StylistIdentifier]) -> Content) {
        self.tokens = tokens.map { StylistIdentifier($0) }
        self.contents = contents
    }

    public init(stylistIdentifiers: [StylistIdentifier], contents: @escaping ([StylistIdentifier]) -> Content) {
        self.tokens = stylistIdentifiers
        self.contents = contents
    }

    public var body: some View {
        // Create the identifier from the current stylist group and our tokens
        let path = self.currentStylableGroup ?? .empty
        let identifiers = self.tokens.map { $0.within(path) }

        // Use it to create the body
        return self.contents(identifiers)
    }
}

public extension WithStylistIdentifier {

    init(token: String,
                @ViewBuilder contents: @escaping (StylistIdentifier) -> Content) {
        self.tokens = [ StylistIdentifier(token) ]
        self.contents = { contents($0[0]) }
    }

    init(tokens token1: String, _ token2: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ StylistIdentifier(token1), StylistIdentifier(token2) ]
        self.contents = { contents($0[0], $0[1]) }
    }

    init(tokens token1: String, _ token2: String, _ token3: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ StylistIdentifier(token1), StylistIdentifier(token2), StylistIdentifier(token3) ]
        self.contents = { contents($0[0], $0[1], $0[2]) }
    }

    init(tokens token1: String, _ token2: String, _ token3: String, _ token4: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ StylistIdentifier(token1), StylistIdentifier(token2), StylistIdentifier(token3), StylistIdentifier(token4) ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3]) }
    }

    init(tokens token1: String, _ token2: String, _ token3: String, _ token4: String, _ token5: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ StylistIdentifier(token1), StylistIdentifier(token2), StylistIdentifier(token3), StylistIdentifier(token4), StylistIdentifier(token5) ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3], $0[4]) }
    }
}

public extension WithStylistIdentifier {

    init(token: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier) -> Content) {
        self.tokens = [ token ]
        self.contents = { contents($0[0]) }
    }

    init(tokens token1: StylistIdentifier, _ token2: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2 ]
        self.contents = { contents($0[0], $0[1]) }
    }

    init(tokens token1: StylistIdentifier, _ token2: StylistIdentifier, _ token3: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2, token3 ]
        self.contents = { contents($0[0], $0[1], $0[2]) }
    }

    init(tokens token1: StylistIdentifier, _ token2: StylistIdentifier, _ token3: StylistIdentifier, _ token4: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2, token3, token4 ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3]) }
    }

    init(tokens token1: StylistIdentifier, _ token2: StylistIdentifier, _ token3: StylistIdentifier, _ token4: StylistIdentifier, _ token5: StylistIdentifier,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2, token3, token4, token5 ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3], $0[4]) }
    }
}

