//
//  StylistIdentifierTests.swift
//

import Foundation
import XCTest

@testable import StylableSwiftUI

private extension StylistIdentifier {
    var identifier: String? { self.component(at: 0).description }
    var element: String? { self.component(at: 1).description }
    var section: String? { self.component(at: 2).description }
}

final class StylistIdentifierTests: XCTestCase {

    func testStylistIdentifier_isWildcard() {
        XCTAssertTrue(StylistIdentifier("").isWildcard)
        XCTAssertTrue(StylistIdentifier("*").isWildcard)
        XCTAssertTrue(StylistIdentifier("*/*/*").isWildcard)

        XCTAssertFalse(StylistIdentifier("a").isWildcard)
        XCTAssertFalse(StylistIdentifier("*/a").isWildcard)
        XCTAssertFalse(StylistIdentifier("*/a/*").isWildcard)
    }

    func testStylistIdentifier_stringLiteral() {
        let identifier: StylistIdentifier = "a/b/c"

        XCTAssertEqual(identifier.identifier, "c")
        XCTAssertEqual(identifier.element, "b")
        XCTAssertEqual(identifier.section, "a")
    }

    func testStylistIdentifier_emptySectionElement() {
        let identifier = StylistIdentifier("//identifier")

        XCTAssertEqual(identifier.section, "*")
        XCTAssertEqual(identifier.element, "*")
        XCTAssertEqual(identifier.identifier, "identifier")
    }

    func testStylistIdentifier_starInSectionElement() {
        let identifier = StylistIdentifier("*/*/identifier")

        XCTAssertEqual(identifier.section, "*")
        XCTAssertEqual(identifier.element, "*")
        XCTAssertEqual(identifier.identifier, "identifier")
    }

    func testStylistIdentifier_losslessStringConversion() {
        let identifier = StylistIdentifier("a/b/c")
        let description = identifier.description
        let identifier2 = StylistIdentifier(description)

        XCTAssertEqual(identifier.identifier, identifier2.identifier)
        XCTAssertEqual(identifier.element, identifier2.element)
        XCTAssertEqual(identifier.section, identifier2.section)
    }

    func testStylistIdentifier_matches() {
        XCTAssertTrue(StylistIdentifier("*").matches("*/*/*"))

        XCTAssertTrue(StylistIdentifier("*/*/*").matches("*/*/*"))
        XCTAssertTrue(StylistIdentifier("very/specific/identifier").matches("very/specific/identifier"))

        XCTAssertFalse(StylistIdentifier("*/*/identifier").matches("*/*/*"))
        XCTAssertTrue(StylistIdentifier("*/*/*").matches("*/*/identifier"))
        XCTAssertTrue(StylistIdentifier("*").matches("*/*/identifier"))

        XCTAssertTrue(StylistIdentifier("*/*/*").matches("should/*/*"))
        XCTAssertTrue(StylistIdentifier("*/*/*").matches("*/contain/*"))
        XCTAssertTrue(StylistIdentifier("*/*/*").matches("*/*/everything"))

        XCTAssertFalse(StylistIdentifier("*/*/identifier").matches("*/*/*"))
        XCTAssertFalse(StylistIdentifier("*/*/identifier").matches("*/*/identifier2"))

        XCTAssertFalse(StylistIdentifier("*/element/identifier").matches("*/*/identifier"))
        XCTAssertFalse(StylistIdentifier("*/element/identifier").matches("*/element2/identifier"))
        XCTAssertTrue(StylistIdentifier("*/*/identifier").matches("*/element/identifier"))

        XCTAssertFalse(StylistIdentifier("section/*/identifier").matches("*/*/identifier"))
        XCTAssertFalse(StylistIdentifier("section/*/identifier").matches("section2/*/identifier"))
        XCTAssertTrue(StylistIdentifier("*/*/identifier").matches("section/*/identifier"))

        XCTAssertTrue(StylistIdentifier("section/*/atom").matches("section/element/atom"))
    }

    func testStyleIdentifier_matchesDifferentIdentifier() {
        XCTAssertFalse(StylistIdentifier("*/*/identifier").matches("section/element/different-identifier"))
    }

    func testStylistIdentifier_longMatches() {
        XCTAssertTrue(StylistIdentifier("*/*/*/identifier").matches("section/*/identifier"))
    }

    func testStylistIdentifier_comparable() {
        let i1 = StylistIdentifier("a/b/c")
        let i2 = StylistIdentifier("*/*/c")
        let i3 = StylistIdentifier("*/*/*/*")

        XCTAssertGreaterThan(i3, i2)
        XCTAssertGreaterThan(i2, i1)
        XCTAssertGreaterThan(i3, i1)
    }

    func testStylistIdentifier_addingComponentsInRange() {
        let identifier = StylistIdentifier("a/b")

        XCTAssertEqual(identifier.withComponent(value: "x", atIndex: 0), "a/x")
        XCTAssertEqual(identifier.withComponent(value: "x", atIndex: 1), "x/b")
    }

    func testStylistIdentifier_addingComponentsOutOfRange() {
        let identifier = StylistIdentifier("a/b")

        XCTAssertEqual(identifier.withComponent(value: "x", atIndex: 2), "x/a/b")
        XCTAssertEqual(identifier.withComponent(value: "x", atIndex: 3), "x/*/a/b")
    }

    func testStylistIdentifier_removingComponents() {
        let identifier = StylistIdentifier("a/b/c")

        XCTAssertEqual(identifier.withComponent(value: nil, atIndex: 0), "a/b/*")
        XCTAssertEqual(identifier.withComponent(value: nil, atIndex: 4), "*/*/a/b/c")
    }

    func testStylistIdentifier_within() {
        let id1 = StylistIdentifier("element/section/identifier")
        let id2 = StylistIdentifier("screen/section")

        XCTAssertEqual(id1.within(id2), "screen/section/element/section/identifier")
    }

    func testStylistIdentifier_containing() {
        let id1 = StylistIdentifier("element/section/identifier")
        let id2 = StylistIdentifier("screen/section")

        XCTAssertEqual(id2.containing(id1), "screen/section/element/section/identifier")
    }

    func testStylistIdentifier_withinWithEmptyComponents() {
        let id1 = StylistIdentifier("element/*/identifier")
        let id2 = StylistIdentifier("screen/section")

        XCTAssertEqual(id1.within(id2), "screen/section/element/*/identifier")
    }

    func testStylistIdentifier_withinEmptyIdentifier() {
        let empty = StylistIdentifier()

        let i = StylistIdentifier("a/b/c")
        XCTAssertEqual(i.within(empty), i)

        XCTAssertEqual(empty.within(empty), empty)
    }

    func testStylistIdentifier_withinNil() {
        XCTAssertEqual(StylistIdentifier("atom").within(nil).description, "atom")
    }

    func testStylistIdentifier_withState_shouldCompare() {
        XCTAssertGreaterThan(StylistIdentifier("element/atom"), StylistIdentifier("element[selected]/atom"))
    }

    func testStylistIdentifier_withState_shouldMatch() {
        // Identical should match
        XCTAssertTrue(StylistIdentifier("element[selected]/atom").matches("element[selected]/atom"))

        // Not specifying a state matches components with a state
        XCTAssertTrue(StylistIdentifier("element/atom").matches("element[selected]/atom"))
        XCTAssertFalse(StylistIdentifier("element[selected]/atom").matches("element/atom"))

        // State matching should work if the value is a wildcard (though this isn't going to be used much)
        XCTAssertTrue(StylistIdentifier("*/atom").matches("*[selected]/atom"))
        XCTAssertFalse(StylistIdentifier("*[selected]/atom").matches("*/atom"))

        // State matching should work at any level
        XCTAssertTrue(StylistIdentifier("section/element/atom").matches("section/element[selected]/atom"))
        XCTAssertFalse(StylistIdentifier("section/element[selected]/atom").matches("section/element/atom"))
        XCTAssertTrue(StylistIdentifier("section/element/atom").matches("section[disabled]/element/atom"))
        XCTAssertFalse(StylistIdentifier("section[disabled]/element/atom").matches("section/element/atom"))
    }

    func testStylistIdentifier_withState_shouldStringConvert() {
        let identifier: StylistIdentifier = "section[disabled]/button[highlighted]/atom"

        let identifier2 = StylistIdentifier(identifier.description)

        XCTAssertEqual(identifier, identifier2)
    }

    func testStylistIdentifier_shouldDescribeWithOrWithoutState() {
        let identifier = StylistIdentifier(components: [ "atom", "element[disabled]", "section" ])
        XCTAssertEqual(identifier.description, "section/element[disabled]/atom")
    }
}
