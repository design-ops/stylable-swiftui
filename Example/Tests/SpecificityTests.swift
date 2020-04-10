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

    func testSpecifictyCachePerformance() {
        let cache = StylistIdentifier.SpecificityCache(capacity: Int.max)

        measure {
            (1..<10000).forEach { _ in
                _ = cache.specificity(for: ["organism", "*", "element", "*", "atom"])
            }
        }
    }

    func testSpecifictyCachePerformance2() {
        let cache = StylistIdentifier.SpecificityCache(capacity: 0)

        measure {
            (1..<10000).forEach { _ in
                _ = cache.specificity(for: ["organism", "*", "element", "*", "atom"])
            }
        }
    }
}
