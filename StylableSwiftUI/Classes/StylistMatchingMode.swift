//
//  StylistMatchingMode.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 18/06/2020.
//

import Foundation

public protocol StylistMatchingMode {
    func insert(styles: [Style], into: [Style]) -> [Style]
    func firstMatch(styles: [Style], toIdentifier: StylistIdentifier) -> Style?
}

public struct AtomicDesign: StylistMatchingMode {

    public init() { }

    public func insert(styles: [Style], into existingStyles: [Style]) -> [Style] {
        let new = existingStyles + styles
        return new.sorted { $0.identifier < $1.identifier }
    }

    public func firstMatch(styles: [Style], toIdentifier: StylistIdentifier) -> Style? {
        return styles.first { $0.identifier.matches(toIdentifier) }
    }
}

public struct NaturalDesign: StylistMatchingMode {

    public init() { }

    public func insert(styles: [Style], into existingStyles: [Style]) -> [Style] {
        return existingStyles + styles
    }

    public func firstMatch(styles: [Style], toIdentifier: StylistIdentifier) -> Style? {
        return styles.filter { $0.identifier.matches(toIdentifier) }
            .sorted { a, b in
                a.identifier.score(against: toIdentifier) > b.identifier.score(against: toIdentifier)
        }.first
    }
}

extension StylistIdentifier {
    func score(against other: StylistIdentifier) -> Int {
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
                    scores["\(value)[\(state)]"] = score << index
                }
            }
        }

        var result = 0
        for component in self.components {
            guard let value = component.value, let score = scores[value] else {
                continue
            }
            result += score
            if let state = component.state, let stateScore = scores["\(value)[\(state)]"] {
                result += stateScore
            }
        }
        return result
    }
}

