//
//  ImageCache.swift
//

import Foundation
import os

typealias ImageName = String

// A class to hold a cache of images.
final class ImageCache: Sendable {

    private let lock: OSAllocatedUnfairLock<[ImageCacheKey: ImageName]> = OSAllocatedUnfairLock(initialState: [:])

    static let `default` = ImageCache()

    func get(_ key: ImageCacheKey) -> ImageName? {
        return self.lock.withLock { $0[key] }
    }

    func add(_ value: ImageName, for key: ImageCacheKey) {
        self.lock.withLock {
            $0[key] = value
        }
    }

    func clear() {
        self.lock.withLock {
            $0.removeAll()
        }
    }
}
