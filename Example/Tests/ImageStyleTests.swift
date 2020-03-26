//
//  ImageStyleTests.swift
//  SwiftUIStylist_Tests
//
//  Created by Sam Dean on 21/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

@testable import StylableSwiftUI

final class StylistIdentifierImageNameTests: XCTestCase {

    func testStylistIdentifier_produceImageNames_forSingleComponentIdentifier() {
        let identifier: StylistIdentifier = "hello"

        XCTAssertEqual(Array(identifier.potentialImageNames(wildcard: "*", separator: "_", maxLength: 3)),
                       [ "hello", "*_hello", "*_*_hello" ])
    }

    func testStylistIdentifier_produceImageNames_forDoubleComponentIdentifier() {
        let identifier: StylistIdentifier = "hello/world"

        XCTAssertEqual(Array(identifier.potentialImageNames(wildcard: "*", separator: "_", maxLength: 3)),
                       [ "hello_world", "*_world", "world", "*_hello_world", "*_*_world" ])
    }

    func testStylistIdentifier_produceImageNames_forTripleComponentIdentifier() {
        let identifier: StylistIdentifier = "searchbar/primary/image"

        XCTAssertEqual(Array(identifier.potentialImageNames(wildcard: "*", separator: "_", maxLength: 4)),
                       [
                        "searchbar_primary_image", "*_primary_image", "searchbar_*_image", "*_*_image",
                        "primary_image", "*_image", "image",
                        "*_searchbar_primary_image", "*_*_primary_image", "*_searchbar_*_image", "*_*_*_image"
        ])
    }

    func testStylistIdentifier_produceImageNames_forWildcardComponents() {
        let identifier:StylistIdentifier = "a/*/c"

        XCTAssertEqual(Array(identifier.potentialImageNames(wildcard: "*", separator: "_", maxLength: 0)),
                       [ "a_*_c", "*_*_c", "*_c", "c" ])
    }

    func testStylistIdentifier_produceImageNames_tinyMaxLength() {
        let identifier: StylistIdentifier = "hello/world"

        XCTAssertEqual(Array(identifier.potentialImageNames(wildcard: "*", separator: "_", maxLength: 1)),
                       [ "hello_world", "*_world", "world" ])
    }

    func testStylistIdentifier_produceImageNames_customWildcardAndSeparator() {
        let identifier: StylistIdentifier = "searchbar/primary/image"

        XCTAssertEqual(Array(identifier.potentialImageNames(wildcard: "^", separator: "-", maxLength: 4)),
                       [
                        "searchbar-primary-image", "^-primary-image", "searchbar-^-image", "^-^-image",
                        "primary-image", "^-image", "image",
                        "^-searchbar-primary-image", "^-^-primary-image", "^-searchbar-^-image", "^-^-^-image"
        ])
    }

    func testStylistIdentifier_produceImageNames_withState() {
        let identifier: StylistIdentifier = "element[disabled]/atom"

        XCTAssertEqual(Array(identifier.potentialImageNames(maxLength: 0)),
                       [ "element[disabled]_atom", "element_atom", "*[disabled]_atom", "*_atom", "atom" ])
    }
}

final class StylistIdentifierPerformanceTests: XCTestCase {

    private let identifier: StylistIdentifier = "a/b/c/d/e/f/g/h/i/j"

    func testStylistIdentifier_potentialImageNames_bestCasePerformanceTest() {
        // Best case - we only want the first element
        measure {
            _ = identifier.potentialImageNames().first
        }
    }

    func testStylistIdentifier_potentialImageNames_worstCasePerformanceTest() {
        // Worst case - we want the last element
        measure {
            _ = identifier.potentialImageNames().map { $0 }.last
        }
    }

    func testStylistIdentifier_potentialImageNames_realCasePerformanceTest() {
        let identifier: StylistIdentifier = "section/organism/element/molecule/atom"
        measure {
            _ = identifier.potentialImageNames().map { $0 }.last
        }
    }
}
