//
//  Specificity.swift
//  StylableSwiftUI
//
//  Created by Sam Dean on 10/04/2020.
//

import Foundation

extension StylistIdentifier {

    /// A structure representing how specific a stylist identifier is.
    ///
    /// The actual value isn't useful (and is accordingly private), it's only useful when comparing with
    /// other `Specificity` values.
    struct Specificity {

        private let value: UInt

        init(components: [StylistIdentifier.Component]) {
            let result = components.reversed().reduce((index: 0, score: UInt(0))) { result, component in
                var result = result
                result.index += 1
                if component.value != nil {
                    result.score |= 1 << result.index
                }
                result.index += 1
                if component.state != nil {
                    result.score |= 1 << result.index
                }
                return result
            }

            self.value = result.score
        }
    }
}

extension StylistIdentifier {
    func score(against other: StylistIdentifier) -> Int {
        var result = 0
        var scores: [String: Int] = [:]
        var score = 0
        for (index, component) in other.components.reversed().enumerated() {
            score += 1
            // One score if we only match the value, and more if we match the value
            // and the state
            if let value = component.value {
                scores[value] = score << index
                if let state = component.state {
                    score += 1
                    scores["\(value)-\(state)"] = score << index
                }
            }
        }
        for component in self.components {
            if let value = component.value,
                let score = scores[value] {
                result += score
                if let state = component.state, let stateScore = scores["\(value)-\(state)"] {
                    result += stateScore
                }
            }
        }
        return result
    }
}

extension StylistIdentifier.Specificity: Equatable, Hashable, Comparable {

    static func < (lhs: StylistIdentifier.Specificity, rhs: StylistIdentifier.Specificity) -> Bool {
        return lhs.value < rhs.value
    }
}
