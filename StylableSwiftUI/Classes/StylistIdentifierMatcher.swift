//
//  StylistIdentifierMatcher.swift
//  StylableSwiftUI
//
//  Created by Sam Dean on 189/07/2020.
//

import Foundation

/// Use this to check whether two `StylistIdentifier`s match.
///
/// Specifically, this will tell if a stylist identifier is a more general version of another.
struct StylistIdentifierMatcher {

    private let logger: Logger

    init(logger: Logger = .default) {
        self.logger = logger
    }

    /// Returns a value > `0` if the lhs matches the partial identifier on the rhs, `0` otherwise.
    ///
    /// i.e.
    ///
    /// matches("home/header/searchBar/label", "home") == 1
    /// matches("home/header/searchBar/label", "header") == 2
    /// matches("home/header/searchBar/label", "home/searchBar") == 5
    /// matches("home/header/searchBar/label", "home/potato") == 0
    ///
    func match(specific lhs: StylistIdentifier, general rhs: StylistIdentifier) -> Int {
        self.logger.debug("Attempting to match \(lhs) with \(rhs)")

        guard lhs.token == rhs.token else { return 0 }

        // If the rhs was just a token (and it's matched to get this far) then it's the weakest possible match
        guard !rhs.path.components.isEmpty else { return 1 }

        // If the lhs is just a token, but the rhs was more than that then the rhs doesn't match
        guard !lhs.path.components.isEmpty else { return 0 }

        // Sanity skip of some maths. If they are identical, it's the best possible match.
        guard lhs != rhs else {
            self.logger.debug("  Exact match")
            return (2<<lhs.path.components.count) - 1
        }

        // We are going to manually step over the rhs, so we will need an iterator
        var rhsIterator = rhs.path.components.makeIterator()
        var rhsComponent = rhsIterator.next()

        var score = 0 // The score we will return if it turns out to be a match
        var nextScore = 2<<(lhs.path.components.count-1) // The score value of the current component - this goes up each time

        // Go through each component of each identifier in turn.
        //
        // If the lhs one doesn't match, move on to the next.
        // If the rhs one doesn't match then abort and return 0.
        for lhsComponent in lhs.path.components {
            defer {
                // Each component in the lhs which matches is more important than the last one. Increase it's score to take that
                // into account
                nextScore /= 2
            }

            self.logger.debug("  Comparing \(lhsComponent) to \(rhsComponent ?? "<nil>")")

            // If this doesn't match the rhs component, move on to the next one
            if lhsComponent != rhsComponent {
                self.logger.debug("   └─No match - movng on to next lhs component")
                continue
            }

            self.logger.debug("   └─Match")

            // Increment the score
            // TODO: Make the score reflect the position of a match i.e. a atom match isn't worth as much as a section match
            score += nextScore

            // Move on to the next rhs component - and if we are at the end, we have matched and just return the score
            rhsComponent = rhsIterator.next()

            if rhsComponent == nil {
                self.logger.debug("  End of rhs - match found")
                return score
            }
        }

        // If we have got to the end of the lhs then we haven't matched everything in the rhs - no match
        self.logger.debug("  End of lhs, but rhs still has matches - no match")

        return 0
    }
}
