//
//  ImageCacheKey.swift
//

import Foundation

struct ImageCacheKey: Hashable {

    var identifier: StylistIdentifier
    var theme: Theme?

    init(identifier: StylistIdentifier, theme: Theme?) {
        self.identifier = identifier
        self.theme = theme
    }
}
