//
//  StylistIdentifierTests.swift
//

import Foundation
import XCTest

@testable import StylableSwiftUI

private extension StylistIdentifier {
    var identifier: String? { self.token }
    var element: String? { self.path.component(at: 0)?.description }
    var section: String? { self.path.component(at: 1)?.description }
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

    func testStylistIdentifier_within() {
        let identifier = StylistIdentifier("element/section/identifier")
        let path = StylistIdentifier.Path("screen/section")

        XCTAssertEqual(identifier.within(path), "screen/section/element/section/identifier")
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
        let path = StylistIdentifier.Path(components: [ "element[disabled]", "section" ])
        let identifier = StylistIdentifier(token: "atom", path: path, theme: nil)
        XCTAssertEqual(identifier.description, "section/element[disabled]/atom")
    }
}
