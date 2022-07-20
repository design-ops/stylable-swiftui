//
//  DebugStylist.swift
//

import Foundation
import SwiftUI

/// Helpful view for debugging - this will output the currentStyleGroup.
///
public struct DebugCurrentStyleGroup<Content>: View where Content: View {

    @Environment(\.currentStylableGroup) private var currentStylableGroup

    private let tag: String?

    private let content: Content

    /// - parameter tag: An optional string to output to the console along with the current style group
    public init(tag: String? = nil, @ViewBuilder content: () -> Content) {
        self.tag = tag
        self.content = content()
    }

    public var body: some View {
        Logger.default.log(tag.map { "StyleIdentifier (\($0)):" } ?? "StyleIdentifier:", self.currentStylableGroup ?? "*", level: .debug)
        return self.content
    }
}

extension DebugCurrentStyleGroup where Content == Image {

    /// Convenience init method which doesn't require a content block.
    ///
    /// It creates an image view with an impossible image name so we are definitely rendering (using EmptyView didn't call body -
    /// I suspect some optimisation by SwiftUI).
    public init(tag: String? = nil) {
        self.init(tag: tag, content: { Image("this is just to make sure we are rendered") })
    }
}
