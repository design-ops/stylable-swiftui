//
//  ImageCacheKey.swift
//
#if os(iOS)
import Foundation

struct ImageCacheKey: Hashable {
    var identifier: StylistIdentifier
    var theme: Theme?
}
#endif
