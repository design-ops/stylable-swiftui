//
//  NaturalDesignMatchingModeTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Kerr Marin Miller on 18/06/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SwiftUI
@testable import StylableSwiftUI

final class NaturalDesignMatchingModeTests: XCTestCase {

    func testPerformance_ofSorting_usingNDS() throws {
        // This is an example of a performance test case.
        self.measure {
            let initialStyles = [
                Style("this/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/is/a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/is/not/matching", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/a/test/not/matching", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("thisnot/matching/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/anot/matching/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("not/matchingthis/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("thisnot/matching/is/a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/not/matchinga/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/testnot/matching", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("not/matching/this/is/a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("a/b/c/x/this/a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("thisa/b/c/x//test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/is/a/a/b/c/x/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/a/testa/b/c/x/", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/a/b/c/x/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("this/is/a/testa/b/c/x/", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
                Style("thisa/b/c/x//a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
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
            Style("this", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
            Style("this/is", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() }),
            Style("this/is/a", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() })
        ]
        let styleA = Style("this/is/a/test", apply: { _ -> EmptyView in XCTFail("Should not be called"); return EmptyView() })
        let styles = matchingMode.insert(styles: [styleA], into: initialStyles)
        XCTAssertTrue(styles.count == 4)
        XCTAssertEqual(styles.last?.identifier, "this/is/a/test")
    }
}
