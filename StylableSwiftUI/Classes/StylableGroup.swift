//
//  StylableGroup.swift
//

import Foundation
import SwiftUI

struct CurrentStylableGroupKey: EnvironmentKey {
    static let defaultValue: StylistIdentifier.Path? = nil
}

extension EnvironmentValues {
    var currentStylableGroup: StylistIdentifier.Path? {
        get {
            return self[CurrentStylableGroupKey.self]
        }
        set {
            self[CurrentStylableGroupKey.self] = newValue
        }
    }
}

public struct StylableGroup<Content>: View where Content: View {

    @Environment(\.currentStylableGroup) private var currentStylableGroup
    private let path: StylistIdentifier.Path?

    private let content: () -> Content

    public init(_ path: StylistIdentifier.Path?, @ViewBuilder content: @escaping () -> Content) {
        self.path = path
        self.content = content
    }

    public init(_ path: String?, @ViewBuilder content: @escaping () -> Content) {
        self.init(path.map { StylistIdentifier.Path($0) }, content: content )
    }

    public var body: some View {
        // If we are already nested within a stylable group, join the together.
        // Otherwise, just use our path
        let path: StylistIdentifier.Path?
        if let currentStylableGroup = self.currentStylableGroup {
            path = self.path?.within(currentStylableGroup)
        } else {
            path = self.path
        }

        // Just return our nested content, but with the environment stylable path updated
        return self.content().environment(\.currentStylableGroup, path)
    }
}
