//
//  NaturalDesignMatchingModeTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Kerr Marin Miller on 18/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import StylableSwiftUI

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
}
