//
//  SpecificityTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Sam Dean on 10/04/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

@testable import StylableSwiftUI

final class SpecificityTests: XCTestCase {

    func testSpecifictyPerformance() {
        measure {
            (1..<10000).forEach { _ in
                _ = StylistIdentifier.Specificity(components: ["organism", "*", "element", "*", "atom"])
            }
        }
    }

    func testSpecifictyPerformance_nds() {
        measure {
            let wholeIdentifier = StylistIdentifier(components: ["organism", "section", "element", "atom"])
            let partialIdentifier = StylistIdentifier(components: ["section", "atom"])
            (1..<10000).forEach { _ in
                _ = partialIdentifier.score(against: wholeIdentifier)
            }
        }
    }

    func testSpecificity_shouldReturnCorrectOrder() {
        let wholeIdentifier = StylistIdentifier(stringLiteral: "home/header/searchBar/label")
        let missingHome = StylistIdentifier(stringLiteral: "*/header/searchBar/label")
        let missingHeader = StylistIdentifier(stringLiteral: "home/*/searchBar/label")
        let missingSearchBar = StylistIdentifier(stringLiteral: "home/header/*/label")
        let missingHomeAndHeader = StylistIdentifier(stringLiteral: "*/*/searchBar/label")
        let missingHomeAndSearchBar = StylistIdentifier(stringLiteral: "*/header/*/label")
        let missingHeaderAndSearchBar = StylistIdentifier(stringLiteral: "home/*/*/label")
        let onlyLabel = StylistIdentifier(stringLiteral: "*/*/*/label")
        let wiSpec = StylistIdentifier.Specificity(components: wholeIdentifier.components)
        let missingHomeSpec = StylistIdentifier.Specificity(components: missingHome.components)
        let missingHeaderSpec = StylistIdentifier.Specificity(components: missingHeader.components)
        let missingSearchBarSpec = StylistIdentifier.Specificity(components: missingSearchBar.components)
        let missingHomeAndHeaderSpec = StylistIdentifier.Specificity(components: missingHomeAndHeader.components)
        let missingHomeAndSearchBarSpec = StylistIdentifier.Specificity(components: missingHomeAndSearchBar.components)
        let missingHeaderAndSearchBarSpec = StylistIdentifier.Specificity(components: missingHeaderAndSearchBar.components)
        let onlyLabelSpec = StylistIdentifier.Specificity(components: onlyLabel.components)

        XCTAssertTrue(wiSpec > missingHomeSpec)
        XCTAssertTrue(missingHomeSpec > missingHeaderSpec)
        XCTAssertTrue(missingHeaderSpec > missingSearchBarSpec)
        XCTAssertTrue(missingSearchBarSpec < missingHomeAndHeaderSpec) // that symbol is intentional
        XCTAssertTrue(missingHomeAndHeaderSpec > missingHomeAndSearchBarSpec)
        XCTAssertTrue(missingHomeAndSearchBarSpec > missingHeaderAndSearchBarSpec)
        XCTAssertTrue(missingHeaderAndSearchBarSpec > onlyLabelSpec)
    }

    func testSpecificityOfNDS_shouldReturnCorrectOrder() {
        let wholeIdentifier = StylistIdentifier(stringLiteral: "home/header/searchBar/label")
        let missingHome = StylistIdentifier(stringLiteral: "header/searchBar/label")
        let missingHeader = StylistIdentifier(stringLiteral: "home/searchBar/label")
        let missingSearchBar = StylistIdentifier(stringLiteral: "home/header/label")
        let missingHomeAndHeader = StylistIdentifier(stringLiteral: "searchBar/label")
        let missingHomeAndSearchBar = StylistIdentifier(stringLiteral: "header/label")
        let missingHeaderAndSearchBar = StylistIdentifier(stringLiteral: "home/label")
        let onlyLabel = StylistIdentifier(stringLiteral: "label")
        let wiSpec = wholeIdentifier.score(against: wholeIdentifier)
        let missingHomeSpec = missingHome.score(against: wholeIdentifier)
        let missingHeaderSpec = missingHeader.score(against: wholeIdentifier)
        let missingSearchBarSpec = missingSearchBar.score(against: wholeIdentifier)
        let missingHomeAndHeaderSpec = missingHomeAndHeader.score(against: wholeIdentifier)
        let missingHomeAndSearchBarSpec = missingHomeAndSearchBar.score(against: wholeIdentifier)
        let missingHeaderAndSearchBarSpec = missingHeaderAndSearchBar.score(against: wholeIdentifier)
        let onlyLabelSpec = onlyLabel.score(against: wholeIdentifier)

        XCTAssertTrue(wiSpec > missingHomeSpec)
        XCTAssertTrue(missingHomeSpec > missingHeaderSpec)
        XCTAssertTrue(missingHeaderSpec > missingSearchBarSpec)
        XCTAssertTrue(missingSearchBarSpec < missingHomeAndHeaderSpec) // that symbol is intentional
        XCTAssertTrue(missingHomeAndHeaderSpec > missingHomeAndSearchBarSpec)
        XCTAssertTrue(missingHomeAndSearchBarSpec > missingHeaderAndSearchBarSpec)
        XCTAssertTrue(missingHeaderAndSearchBarSpec > onlyLabelSpec)
    }

    func testSpecificityOfNDS_withStates_shouldReturnCorrectOrder() {
        let wholeIdentifier = StylistIdentifier(stringLiteral: "home/header/searchBar/label[selected]")

        let missingHome = StylistIdentifier(stringLiteral: "header/searchBar/label")
        let missingHomeAndSearchBar = StylistIdentifier(stringLiteral: "header/label")
        let missingHeaderAndSearchBar = StylistIdentifier(stringLiteral: "home/label[selected]")
        let onlyLabel = StylistIdentifier(stringLiteral: "label[selected]")
        let wiSpec = wholeIdentifier.score(against: wholeIdentifier)
        let missingHomeSpec = missingHome.score(against: wholeIdentifier)
        let missingHomeAndSearchBarSpec = missingHomeAndSearchBar.score(against: wholeIdentifier)
        let missingHeaderAndSearchBarSpec = missingHeaderAndSearchBar.score(against: wholeIdentifier)
        let onlyLabelSpec = onlyLabel.score(against: wholeIdentifier)

        XCTAssertTrue(wiSpec > missingHomeSpec)
        XCTAssertTrue(missingHomeAndSearchBarSpec < missingHeaderAndSearchBarSpec) // this one is most specific because of [selected]
        XCTAssertTrue(missingHeaderAndSearchBarSpec > onlyLabelSpec)
        XCTAssertTrue(onlyLabelSpec > missingHomeAndSearchBarSpec)
    }
}
