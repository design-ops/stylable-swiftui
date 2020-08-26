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

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "_")),
                       [ "hello" ])
    }

    func testStylistIdentifier_produceImageNames_forDoubleComponentIdentifier() {
        let identifier: StylistIdentifier = "hello/world"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "_")),
                       [ "hello_world", "world" ])
    }

    func testStylistIdentifier_produceImageNames_forTripleComponentIdentifier() {
        let identifier: StylistIdentifier = "searchbar/primary/image"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "_")),
                       [ "searchbar_primary_image",
                         "primary_image",
                         "searchbar_image",
                         "image" ])
    }

    func testStylistIdentifier_produceImageNames_customSeparator() {
        let identifier: StylistIdentifier = "searchbar/primary/image"

        XCTAssertEqual(Array(identifier.potentialImageNames(separator: "-")),
                       [ "searchbar-primary-image",
                         "primary-image",
                         "searchbar-image",
                         "image" ])

    }

    func testStylistIdentifier_produceImageNames_withState() {
        let identifier: StylistIdentifier = "element[disabled]/atom"

        XCTAssertEqual(Array(identifier.potentialImageNames()),
                       [ "element[disabled]_atom",
                         "element_atom",
                         "atom" ])
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
