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
        self.content().environment(\.currentStylableGroup, self.path?.within(self.currentStylableGroup))
    }
}
