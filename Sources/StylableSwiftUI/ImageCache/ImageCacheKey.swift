//
//  ImageCacheKey.swift
//
import Foundation

struct ImageCacheKey: Hashable {
    var identifier: StylistIdentifier
    var theme: Theme?
}
