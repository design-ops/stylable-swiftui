//
//  StylistTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Kerr Marin Miller on 09/04/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SwiftUI

@testable import StylableSwiftUI

final class StylistTests: XCTestCase {
    func testStylist() throws {
        let stylist = Stylist()

        var didApplyGeneral = false
        var didApplySpecific = false
        stylist.addStyle(identifier: "*/*/element/atom") { view -> AnyView in
            didApplySpecific = true
            return AnyView(view.foregroundColor(.red))
        }

        stylist.addStyle(identifier: "*/organism/*/atom") { view -> AnyView in
            didApplyGeneral = true
            return AnyView(view.foregroundColor(.blue))
        }

        let stylable = Stylable(AnyView(Text("Test")), identifier: "element/atom")
        _ = stylist.style(view: stylable, identifier: "element/atom")

        XCTAssertFalse(didApplyGeneral)
        XCTAssertTrue(didApplySpecific)
    }
}
