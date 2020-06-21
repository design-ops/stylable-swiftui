//
//  NaturalDesignMatchingModeTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Kerr Marin Miller on 18/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import StylableSwiftUI
import SwiftUI

final class NaturalDesignMatchingModeTests: XCTestCase {

    func testPerformance_ofSorting_usingNDS() throws {
        // This is an example of a performance test case.
        self.measure {
            let initialStyles = [
                Style("this/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/is/a/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/a/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/is/not/matching", apply: { _ in fatalError("Should not be called") }),
                Style("this/a/test/not/matching", apply: { _ in fatalError("Should not be called") }),
                Style("this", apply: { _ in fatalError("Should not be called") }),
                Style("thisnot/matching/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/anot/matching/test", apply: { _ in fatalError("Should not be called") }),
                Style("not/matchingthis/test", apply: { _ in fatalError("Should not be called") }),
                Style("thisnot/matching/is/a/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/not/matchinga/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/testnot/matching", apply: { _ in fatalError("Should not be called") }),
                Style("not/matching/this/is/a/test", apply: { _ in fatalError("Should not be called") }),
                Style("a/b/c/x/this/a/test", apply: { _ in fatalError("Should not be called") }),
                Style("thisa/b/c/x//test", apply: { _ in fatalError("Should not be called") }),
                Style("this/is/a/a/b/c/x/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/a/testa/b/c/x/", apply: { _ in fatalError("Should not be called") }),
                Style("this/a/b/c/x/test", apply: { _ in fatalError("Should not be called") }),
                Style("this/is/a/testa/b/c/x/", apply: { _ in fatalError("Should not be called") }),
                Style("thisa/b/c/x//a/test", apply: { _ in fatalError("Should not be called") }),
            ]
            let matchingMode = NaturalDesign()

            (1..<10000).forEach { _ in
                _ = matchingMode.firstMatch(styles: initialStyles.shuffled(), toIdentifier: "this/is/a/test")
            }
        }
    }

    func testInserting_withPreviousItems_shouldAddToTheEndOfTheArray() throws {
        let matchingMode = NaturalDesign()
        let initialStyles = [
            Style("this", apply: { _ in fatalError("Should not be called") }),
            Style("this/is", apply: { _ in fatalError("Should not be called") }),
            Style("this/is/a", apply: { _ in fatalError("Should not be called") })
        ]
        let styleA = Style("this/is/a/test", apply: { _ in fatalError("Should not be called") })
        let styles = matchingMode.insert(styles: [styleA], into: initialStyles)
        XCTAssertTrue(styles.count == 4)
        XCTAssertEqual(styles.last?.identifier, "this/is/a/test")
    }

    func testNaturalDesgn_shouldMatchStyles_accordingToReadme() {
        // From the readme, an element with identifier "home/header/searchBar/label" should be matched by
        //
        // home/header/searchBar/label
        // header/searchBar/label
        // home/searchBar/label
        // home/header/label
        // searchBar/label
        // header/label
        // home/label
        // label
        //
        // We're going to test that NaturalDesign maqtches these, in turn.
        //
        // This test _doesn't_ test for matching in the right order, just santy checks that they all match

        let tests = [
            "home/header/searchBar/label",
            "header/searchBar/label",
            "home/searchBar/label",
            "home/header/label",
            "searchBar/label",
            "header/label",
            "home/label",
            "label"
        ]

        for identifier in tests {
            let style = Style(StylistIdentifier(identifier), apply: { $0 })

            let mode = NaturalDesign()

            let styles = mode.insert(styles: [style], into: [])

            let match = mode.firstMatch(styles: styles, toIdentifier: "home/header/searchBar/label")
            XCTAssertNotNil(match, "Expected style with identifier '\(identifier)' to match element with identifier 'home/header/searchBar/label'")
        }
    }
}
