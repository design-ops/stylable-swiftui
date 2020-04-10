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
    ///
    /// - note: These are designed to be accessed via the `SpecificityCache` - they're not trivial to calculate.
    struct Specificity: Equatable, Hashable, Comparable {

        private let value: UInt

        fileprivate init(value: UInt) {
            self.value = value
        }

        static func < (lhs: Specificity, rhs: Specificity) -> Bool {
            return lhs.value < rhs.value
        }
    }

    /// Responsible for calculating and caching specificity values for a given array of components.
    final class SpecificityCache {

        /// Store specificity values for identifiers
        private var cache: [[StylistIdentifier.Component]: Specificity] = [:]

        /// Global singleton instance of the specificty cache
        static let shared = SpecificityCache()

        /// Returns the specificity value from the array of components.
        ///
        /// - note: Returns the cached value if possible, otherwise stores the value in the cache
        func specificity(for components: [StylistIdentifier.Component]) -> Specificity {
            if let specificity = self.cache[components] {
                //print("[SpecificityCache]", "Found score \(specificity) for \(components)")
                return specificity
            }

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

            let specificity = Specificity(value: result.score)

            self.cache[components] = specificity
            //print("[SpecificityCache]", "Stored score \(specificity) for \(components)")

            return specificity
        }
    }
}
