//
//  ImageCache.swift
//
#if os(iOS)
import Foundation

typealias ImageName = String

// A class to hold a cache of images.
// This class is not thread safe. Do not call it from multiple threads concurrently.
final class ImageCache {

    private var cache: [ImageCacheKey: ImageName] = [:]

    static let `default` = ImageCache()

    func get(_ key: ImageCacheKey) -> ImageName? {
        return self.cache[key]
    }

    func add(_ value: ImageName, for key: ImageCacheKey) {
        self.cache[key] = value
    }

    func clear() {
        self.cache = [:]
    }
}
#endif
