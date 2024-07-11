//
//  ImageCacheTests.swift
//  StylableSwiftUI_Tests
//
//  Created by Kerr Marin Miller on 9/8/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import StylableSwiftUI

final class ImageCacheTests: XCTestCase {

    func testPerformanceOfCache() throws {

        let longestIdentifier = "dark/home/header[selected]/searchBar[deselected]/label"
        let longerIdentifier = "dark/home/searchBar[deselected]/label"
        let identifier = "dark/label"

        #if !NOT_SPM
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: ImageCacheTests.self)
        #endif

        self.measure {
            for _ in 1..<1000 {
                XCTAssertNotNil(StylistIdentifier(longestIdentifier).uiImage(bundle: bundle))
                XCTAssertNotNil(StylistIdentifier(longerIdentifier).uiImage(bundle: bundle))
                XCTAssertNotNil(StylistIdentifier(identifier).uiImage(bundle: bundle))
            }
        }
    }
}
