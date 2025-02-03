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
        let matcher = StylistIdentifierMatcher(mode: .classic)

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
        let matcher = StylistIdentifierMatcher(mode: .classic)

        let specific = StylistIdentifier("home/header/searchBar/label")
        XCTAssertEqual(matcher.match(specific: specific, general: ""), 0)
        XCTAssertEqual(matcher.match(specific: specific, general: "label/searchBar"), 0)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header/searchBar/label/extra"), 0)
    }

    func testStylistIdentifier_matchesWithVariants() {
        let matcher = StylistIdentifierMatcher(mode: .classic)

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
        let matcher = StylistIdentifierMatcher(mode: .classic)

        let specific: StylistIdentifier = "home/header[selected]/searchBar[deselected]/label"
        // NOTE - scores per component:    2(4)  8        16        32         64

        // If the general has a variant but the specific doesn't then it won't match
        XCTAssertEqual(matcher.match(specific: specific, general: "home[selected]/label"), 0)

        // If the variants don't match between the general and the specific, then it's not a match
        XCTAssertEqual(matcher.match(specific: specific, general: "header[normal]/label"), 0)
    }

    func testStylistIdentifier_themedIdentifier() {
        let matcher = StylistIdentifierMatcher(mode: .classic)

        let specific: StylistIdentifier = "home/header[selected]/searchBar[deselected]/label"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/home/header[selected]/searchBar[deselected]/label"), MatcherScore.unthemedMax + 1)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/home/searchBar[deselected]/label"), 99)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/label"), 2)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header[selected]/searchBar[deselected]/label"), MatcherScore.unthemedMax)
    }

    func testStylistIdentifier_testExactMatchWithThemes() {
        let matcher = StylistIdentifierMatcher(mode: .classic)

        let specific: StylistIdentifier = "button-primary/title"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/title"), 2)
        XCTAssertEqual(matcher.match(specific: specific, general: "button-primary/title"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/button-primary/title"), MatcherScore.unthemedMax+1)
    }

    func testStylistIdentifier_withThemes() {
        let matcher = StylistIdentifierMatcher(mode: .classic)

        let specific: StylistIdentifier = "settings/modal/form-group/form-field/form-type-group-list/form-type-select/background"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/settings/modal/form-group/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax + 1)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/modal/form-group/form-field/form-type-group-list/form-type-select/background"), 2729)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-group/form-field/form-type-group-list/form-type-select/background"), 2721)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-field/form-type-group-list/form-type-select/background"), 2689)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-type-group-list/form-type-select/background"), 2561)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-type-select/background"), 2049)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/background"), 2)
        XCTAssertEqual(matcher.match(specific: specific, general: "settings/modal/form-group/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "modal/form-group/form-field/form-type-group-list/form-type-select/background"), 2728)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-group/form-field/form-type-group-list/form-type-select/background"), 2720)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-field/form-type-group-list/form-type-select/background"), 2688)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-type-group-list/form-type-select/background"), 2560)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-type-select/background"), 2048)
        XCTAssertEqual(matcher.match(specific: specific, general: "background"), 1)

    }

    func testStylistIdentifier_themedIdentifier_inThemedPrecedence() {
        let matcher = StylistIdentifierMatcher(mode: .themedPrecedence)

        let specific: StylistIdentifier = "home/header[selected]/searchBar[deselected]/label"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/home/header[selected]/searchBar[deselected]/label"), MatcherScore.unthemedMax*2)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/home/searchBar[deselected]/label"), MatcherScore.unthemedMax + 98)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/label"), MatcherScore.unthemedMax+1)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header[selected]/searchBar[deselected]/label"), MatcherScore.unthemedMax)
    }

    func testStylistIdentifier_testExactMatchWithThemes_inThemedPrecedence() {
        let matcher = StylistIdentifierMatcher(mode: .themedPrecedence)

        let specific: StylistIdentifier = "button-primary/title"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/title"), MatcherScore.unthemedMax+1)
        XCTAssertEqual(matcher.match(specific: specific, general: "button-primary/title"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/button-primary/title"), MatcherScore.unthemedMax*2)
    }

    func testStylistIdentifier_withThemes_inThemedPrecedence() {
        let matcher = StylistIdentifierMatcher(mode: .themedPrecedence)

        let specific: StylistIdentifier = "settings/modal/form-group/form-field/form-type-group-list/form-type-select/background"

        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/settings/modal/form-group/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax*2)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/modal/form-group/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax+2728)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-group/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax+2720)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax+2688)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax+2560)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/form-type-select/background"), MatcherScore.unthemedMax+2048)
        XCTAssertEqual(matcher.match(specific: specific, general: "@dark/background"), MatcherScore.unthemedMax+1)
        XCTAssertEqual(matcher.match(specific: specific, general: "settings/modal/form-group/form-field/form-type-group-list/form-type-select/background"), MatcherScore.unthemedMax)
        XCTAssertEqual(matcher.match(specific: specific, general: "modal/form-group/form-field/form-type-group-list/form-type-select/background"), 2728)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-group/form-field/form-type-group-list/form-type-select/background"), 2720)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-field/form-type-group-list/form-type-select/background"), 2688)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-type-group-list/form-type-select/background"), 2560)
        XCTAssertEqual(matcher.match(specific: specific, general: "form-type-select/background"), 2048)
        XCTAssertEqual(matcher.match(specific: specific, general: "background"), 1)

    }
}
