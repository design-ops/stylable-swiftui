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
        let identifier: ThemedStylistIdentifier = "hello"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "_")),
                       [ "hello" ])
    }

    func testStylistIdentifier_produceImageNames_forDoubleComponentIdentifier() {
        let identifier: ThemedStylistIdentifier = "hello/world"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "_")),
                       [ "hello_world", "world" ])
    }

    func testStylistIdentifier_produceImageNames_forTripleComponentIdentifier() {
        let identifier: ThemedStylistIdentifier = "searchbar/primary/image"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "_")),
                       [ "searchbar_primary_image",
                         "primary_image",
                         "searchbar_image",
                         "image" ])
    }

    func testStylistIdentifier_produceImageNames_customSeparator() {
        let identifier: ThemedStylistIdentifier = "searchbar/primary/image"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "-")),
                       [ "searchbar-primary-image",
                         "primary-image",
                         "searchbar-image",
                         "image" ])

    }

    func testStylistIdentifier_produceImageNames_withState() {
        let identifier: ThemedStylistIdentifier = "element[disabled]/atom"

        XCTAssertEqual(Array(identifier.potentialImageNames()),
                       [ "element[disabled]_atom",
                         "element_atom",
                         "atom" ])
    }

    func testStylistIdentifier_potentialImageNames_withTheme() {
        let identifier: ThemedStylistIdentifier = "@dark/element/atom"

        XCTAssertEqual(Array(identifier.potentialImageNames()),
                       [ "dark_element_atom",
                         "dark_atom",
                         "element_atom",
                         "atom"
                       ])
    }

    func testStylistIdentifier_potentialImageNames_withThemesAndMultipleLevels() {
        let identifier: ThemedStylistIdentifier = "@dark/element/organism/atom"

        XCTAssertEqual(Array(identifier.potentialImageNames()),
                       [ "dark_element_organism_atom",
                         "dark_organism_atom",
                         "dark_element_atom",
                         "dark_atom",
                         "element_organism_atom",
                         "organism_atom",
                         "element_atom",
                         "atom"
                       ])
    }
}

final class StylistIdentifierPerformanceTests: XCTestCase {

    private let identifier: ThemedStylistIdentifier = "a/b/c/d/e/f/g/h/i/j"

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
        let identifier: ThemedStylistIdentifier = "section/organism/element/molecule/atom"
        measure {
            _ = identifier.potentialImageNames().map { $0 }.last
        }
    }
}
