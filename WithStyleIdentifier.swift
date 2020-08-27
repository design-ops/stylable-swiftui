//
//  WithStyleIdentifier.swift
//  Pods-StylableSwiftUI_Example
//
//  Created by Sam Dean on 27/08/2020.
//

import Foundation

import SwiftUI

public struct WithStylistIdentifier<Content: View>: View {

    @Environment(\.currentStylableGroup) private var currentStylableGroup

    private let tokens: [String]

    private let contents: ([StylistIdentifier]) -> Content

    public init(token: String,
                @ViewBuilder contents: @escaping (StylistIdentifier) -> Content) {
        self.tokens = [ token ]
        self.contents = { contents($0[0]) }
    }

    public init(tokens token1: String, _ token2: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2 ]
        self.contents = { contents($0[0], $0[1]) }
    }

    public init(tokens token1: String, token2: String, token3: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2, token3 ]
        self.contents = { contents($0[0], $0[1], $0[2]) }
    }

    public init(tokens token1: String, token2: String, token3: String, token4: String,
                @ViewBuilder contents: @escaping (StylistIdentifier, StylistIdentifier, StylistIdentifier, StylistIdentifier) -> Content) {
        self.tokens = [ token1, token2, token3, token4 ]
        self.contents = { contents($0[0], $0[1], $0[2], $0[3]) }
    }

    public var body: some View {
        // Create the identifier from the current stylist group and our tokens
        let path = self.currentStylableGroup ?? .empty
        let identifiers = self.tokens.map { StylistIdentifier(token: $0, path: path) }

        // Use it to create the body
        return self.contents(identifiers)
    }
}
