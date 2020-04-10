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
}
