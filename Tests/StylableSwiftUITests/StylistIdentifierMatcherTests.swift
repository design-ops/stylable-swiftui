//
//  StylistIdentifierMatcherTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Sam Dean on 19/07/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

import XCTest

@testable import StylableSwiftUI

final class StylistIdentifierMatcherTests: XCTestCase {

    func testStylistIdentifer_matches() {
        let matcher = StylistIdentifierMatcher()

        // Given the element with identifier "home/header/searchBar/label"
        //
        // These styles should all match (taken from the NDS readme):
        //
        // home/header/searchBar/label
        // header/searchBar/label
        // home/searchBar/label
        // home/header/label
        // searchBar/label
        // header/label
        // home/label
        // label

        let specific = StylistIdentifier("home/header/searchBar/label")
        // NOTE - scores per component:   2(4)  8(16)  32(64)
        // NOTE - there is no score attached to 'label' as it always matches.

        XCTAssertEqual(matcher.match(specific: specific, general: "home/header/searchBar/label"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "header/searchBar/label"), 40)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/searchBar/label"), 34)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header/label"), 10)
        XCTAssertEqual(matcher.match(specific: specific, general: "searchBar/label"), 32)
        XCTAssertEqual(matcher.match(specific: specific, general: "header/label"), 8)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/label"), 2)
        XCTAssertEqual(matcher.match(specific: specific, general: "label"), 1)
    }

    func testStylistIdentifer_doesNotMatch() {
        let matcher = StylistIdentifierMatcher()

        let specific = StylistIdentifier("home/header/searchBar/label")
        XCTAssertEqual(matcher.match(specific: specific, general: ""), 0)
        XCTAssertEqual(matcher.match(specific: specific, general: "label/searchBar"), 0)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header/searchBar/label/extra"), 0)
    }

    func testStylistIdentifier_matchesWithVariants() {
        let matcher = StylistIdentifierMatcher()

        let specific: StylistIdentifier = "home/header[selected]/searchBar[deselected]/label"
        // NOTE - scores per component:    2(4)  8        16        32         64

        // Sanity - this should match with a score of 1
        XCTAssertEqual(matcher.match(specific: specific, general: "label"), 1)

        XCTAssertEqual(matcher.match(specific: specific, general: "home/header[selected]/searchBar[deselected]/label"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "header[selected]/searchBar[deselected]/label"), 120)
        XCTAssertEqual(matcher.match(specific: specific, general: "header[selected]/searchBar/label"), 56)
        XCTAssertEqual(matcher.match(specific: specific, general: "header/searchBar[deselected]/label"), 104)
        XCTAssertEqual(matcher.match(specific: specific, general: "header[selected]/label"), 24)
        XCTAssertEqual(matcher.match(specific: specific, general: "header/searchBar/label"), 40)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/label"), 2)
    }

    func testStylistIdentifier_invalidMatchesWithVariants() {
        let matcher = StylistIdentifierMatcher()

        let specific: StylistIdentifier = "home/header[selected]/searchBar[deselected]/label"
        // NOTE - scores per component:    2(4)  8        16        32         64

        // If the general has a variant but the specific doesn't then it won't match
        XCTAssertEqual(matcher.match(specific: specific, general: "home[selected]/label"), 0)

        // If the variants don't match between the general and the specific, then it's not a match
        XCTAssertEqual(matcher.match(specific: specific, general: "header[normal]/label"), 0)
    }

    func testStylistIdentifier_themedIdentifier() {
        let matcher = StylistIdentifierMatcher()

        let specific: StylistIdentifier = "home/header[selected]/searchBar[deselected]/label"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/home/header[selected]/searchBar[deselected]/label"), MatcherScore.themedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/home/searchBar[deselected]/label"), 99)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/label"), 2)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header[selected]/searchBar[deselected]/label"), MatcherScore.unthemedMax)
    }

    func testStylistIdentifier_testExactMatchWithThemes() {
        let matcher = StylistIdentifierMatcher()

        let specific: StylistIdentifier = "button-primary/title"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/title"), 2)
        XCTAssertEqual(matcher.match(specific: specific, general: "button-primary/title"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/button-primary/title"), MatcherScore.themedMax)
    }
}
