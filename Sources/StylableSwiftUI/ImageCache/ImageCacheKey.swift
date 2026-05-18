//
//  ImageCacheKey.swift
//

import Foundation

struct ImageCacheKey: Hashable, Sendable {
    var identifier: StylistIdentifier
    var theme: Theme?
}
