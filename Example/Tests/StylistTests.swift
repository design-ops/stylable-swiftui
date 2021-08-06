//
//  StylistTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Kerr Marin Miller on 09/04/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SwiftUI

@testable import StylableSwiftUI

final class StylistTests: XCTestCase {

    func testStylist() throws {
        let stylist = Stylist()

        var didApplyGeneral = false
        var didApplySpecific = false

        stylist.addStyle(identifier: "element/atom") { view -> AnyView in
            didApplySpecific = true
            return AnyView(view.foregroundColor(.red))
        }

        stylist.addStyle(identifier: "organism/atom") { view -> AnyView in
            didApplyGeneral = true
            return AnyView(view.foregroundColor(.blue))
        }

        let stylable = Stylable(AnyView(Text("Test")), identifier: "element/atom")
        _ = stylist.style(view: stylable, identifier: "element/atom")

        XCTAssertFalse(didApplyGeneral)
        XCTAssertTrue(didApplySpecific)
    }

    func testStylistPerformance() {
        let stylist = Stylist()
        let styles = largeNumberOfStyles()
        stylist.addStyles(styles: { return styles })

        let previousLevel = Logger.default.level
        Logger.default.level = .fault

        measure {
            let id1 = styles.randomElement()?.identifier
            let id2 = styles.randomElement()!.identifier
            for _ in  0..<10_000 {
                _ = stylist.style(view: Stylable(Text("Test"),
                                                 identifier: id1?.identifier),
                                  identifier: id2.identifier)
            }
        }

        Logger.default.level = previousLevel
    }

    func testTheming() {
        let stylist = Stylist()

        var didApplyGeneric = false
        var didApplyThemed = false

        stylist.addStyle(identifier: "element/atom") { view -> AnyView in
            didApplyGeneric = true
            return AnyView(view.foregroundColor(.red))
        }

        stylist.addStyle(identifier: "@dark/element/atom") { view -> AnyView in
            didApplyThemed = true
            return AnyView(view.foregroundColor(.blue))
        }

        stylist.currentTheme = Theme(name: "dark")

        let stylable = Stylable(AnyView(Text("Test")), identifier: "element/atom")
        _ = stylist.style(view: stylable, identifier: "element/atom")

        XCTAssertFalse(didApplyGeneric)
        XCTAssertTrue(didApplyThemed)

        stylist.currentTheme = nil

        didApplyGeneric = false
        didApplyThemed = false

        _ = stylist.style(view: stylable, identifier: "element/atom")

        XCTAssertTrue(didApplyGeneric)
        XCTAssertFalse(didApplyThemed)
    }

    func testThemePrecedence() {
        let stylist = Stylist()

        var didApplyGeneric = false
        var didApplyThemed = false

        stylist.addStyle(identifier: "element/searchBar/header/atom") { view -> AnyView in
            didApplyGeneric = true
            return AnyView(view.foregroundColor(.red))
        }

        stylist.addStyle(identifier: "@dark/atom") { view -> AnyView in
            didApplyThemed = true
            return AnyView(view.foregroundColor(.blue))
        }

        stylist.currentTheme = Theme(name: "@dark")

        var stylable = Stylable(AnyView(Text("Test")), identifier: "element/searchBar/header/atom")
        _ = stylist.style(view: stylable, identifier: "element/searchBar/header/atom")

        XCTAssertFalse(didApplyGeneric)
        XCTAssertTrue(didApplyThemed)

        didApplyGeneric = false
        didApplyThemed = false

        stylable = Stylable(AnyView(Text("Test")), identifier: "header/atom")
        _ = stylist.style(view: stylable, identifier: "header/atom")

        XCTAssertFalse(didApplyGeneric)
        XCTAssertTrue(didApplyThemed)
    }

    func testThemeFallBackToDefault() {
        let stylist = Stylist()

        var didApplyGeneric = false
        var didApplyThemed = false

        stylist.addStyle(identifier: "element/searchBar/header/atom") { view -> AnyView in
            didApplyGeneric = true
            return AnyView(view.foregroundColor(.red))
        }

        stylist.addStyle(identifier: "@dark/differentAtom") { view -> AnyView in
            didApplyThemed = true
            return AnyView(view.foregroundColor(.blue))
        }

        stylist.currentTheme = Theme(name: "dark")

        let stylable = Stylable(AnyView(Text("Test")), identifier: "element/searchBar/header/atom")
        _ = stylist.style(view: stylable, identifier: "element/searchBar/header/atom")

        XCTAssertTrue(didApplyGeneric)
        XCTAssertFalse(didApplyThemed)
    }

    func testPathComponentIdentifiersWithSpecialCharacters() {
        let stylist = Stylist()

        var didApplySpecialCharacter = false
        var didApplyNoSpecialCharacter = false

        stylist.addStyle(identifier: "element/@searchBar/heÆder/atõm") { view -> AnyView in
            didApplySpecialCharacter = true
            return AnyView(view.foregroundColor(.red))
        }

        stylist.addStyle(identifier: "element/searchBar/header/atom") { view -> AnyView in
            didApplyNoSpecialCharacter = true
            return AnyView(view.foregroundColor(.blue))
        }

        let stylable = Stylable(AnyView(Text("Test")), identifier: "element/@searchBar/heÆder/atõm")
        _ = stylist.style(view: stylable, identifier: "element/@searchBar/heÆder/atõm")

        XCTAssertTrue(didApplySpecialCharacter)
        XCTAssertFalse(didApplyNoSpecialCharacter)
    }
}

private var largeNumberOfStyles: () -> [Style] = {
    let combinations = [
        "element1",
        "element2",
        "element3",
        "element4",
        "element5"
    ]
    return combinations.permutations.map { permutation -> Style in
        Style(ThemedStylistIdentifier(identifier: StylistIdentifier(permutation.joined(separator: "/")),
                                      theme: Int.random(in: 0...1) == 0 ? "dark" : nil), apply: {
            $0.background(Color.red)
        })
    }
}

private extension Array {

    func chopped() -> (Element, [Element])? {
        guard let x = self.first else { return nil }
        return (x, Array(self.suffix(from: 1)))
    }

    func interleaved(_ element: Element) -> [[Element]] {
        guard let (head, rest) = self.chopped() else { return [[element]] }
        return [[element] + self] + rest.interleaved(element).map { [head] + $0 }
    }

    var permutations: [[Element]] {
        guard let (head, rest) = self.chopped() else { return [[]] }
        return rest.permutations.flatMap { $0.interleaved(head) }
    }
}

