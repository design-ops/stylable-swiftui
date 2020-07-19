//
//  StylistIdentifierTests.swift
//

import Foundation
import XCTest

@testable import StylableSwiftUI

private extension StylistIdentifier {
    var identifier: String? { self.component(at: 0)?.description }
    var element: String? { self.component(at: 1)?.description }
    var section: String? { self.component(at: 2)?.description }
}

final class StylistIdentifierTests: XCTestCase {

    func testStylistIdentifier_stringLiteral() {
        let identifier: StylistIdentifier = "a/b/c"

        XCTAssertEqual(identifier.identifier, "c")
        XCTAssertEqual(identifier.element, "b")
        XCTAssertEqual(identifier.section, "a")
    }

    func testStylistIdentifier_emptySectionElement() {
        // Will resolve to just "identfier"
        let identifier = StylistIdentifier("//identifier")

        XCTAssertEqual(identifier.section, nil)
        XCTAssertEqual(identifier.element, nil)
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
