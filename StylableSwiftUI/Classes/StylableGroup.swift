//
//  StylableGroup.swift
//

import Foundation
import SwiftUI

struct CurrentStylableGroupKey: EnvironmentKey {
    static let defaultValue: StylistIdentifier? = nil
}

extension EnvironmentValues {
    var currentStylableGroup: StylistIdentifier? {
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
    private let identifier: StylistIdentifier?

    private let content: Content

    public init(_ identifier: StylistIdentifier?, @ViewBuilder content: () -> Content) {
        self.identifier = identifier
        self.content = content()
    }

    public init(_ identifier: String?, @ViewBuilder content: () -> Content) {
        self.init(identifier.map { StylistIdentifier($0) }, content: content)
    }

    public var body: some View {
        self.content.environment(\.currentStylableGroup, identifier?.within(self.currentStylableGroup))
    }
}
