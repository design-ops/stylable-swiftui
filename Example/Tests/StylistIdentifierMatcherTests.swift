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
        // NOTE - scores per component are: 2    4       8
        // NOTE - there is no score attached to 'label' as it always matches.

        XCTAssertEqual(matcher.match(specific: specific, general: "home/header/searchBar/label"), 15)
        XCTAssertEqual(matcher.match(specific: specific, general: "header/searchBar/label"), 12)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/searchBar/label"), 10)
        XCTAssertEqual(matcher.match(specific: specific, general: "home/header/label"), 6)
        XCTAssertEqual(matcher.match(specific: specific, general: "searchBar/label"), 8)
        XCTAssertEqual(matcher.match(specific: specific, general: "header/label"), 4)
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
}
