//
//  StylistIdentifierMatcher.swift
//  StylableSwiftUI
//
//  Created by Sam Dean on 189/07/2020.
//

import Foundation

typealias MatcherScore = Int

extension MatcherScore {
    static let unthemedMax = Int.max - 1
    static let themedMax = Int.max
}

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
    func match(specific lhs: StylistIdentifier, general rhs: ThemedStylistIdentifier) -> MatcherScore {
        self.logger.debug("Attempting to match \(lhs) with \(rhs)")

        guard lhs.token == rhs.token else { return 0 }

        var score = 0 // The score we will return if it turns out to be a match
        if rhs.theme != nil {
            // we have a theme, so we want to override any non-themed, equally-specific identifier.
            score += 1
        }

        // We might be able to save some time here:
        // if it is an exact match, we can return the maximum it could be
        // this will return Int.max if there is a theme and Int.max - 1 if there wasn't a theme. So
        // a themed exact match will override a non-themed exact match
        if lhs.path == rhs.path {
            return .unthemedMax + score
        }

        // If the rhs was just a token (and it's matched to get this far) then it's the weakest possible match.
        // So here we return the current score + 1, which will either be 1 or 1 + the maximum possible value if there was a theme.
        guard !rhs.path.components.isEmpty else { return score + 1 }

        // If the lhs is just a token, but the rhs was more than that then the rhs doesn't match
        guard !lhs.path.components.isEmpty else { return 0 }

        // We are going to manually step over the rhs, so we will need an iterator
        var rhsIterator = rhs.path.components.makeIterator()
        var rhsComponent = rhsIterator.next()

        var nextScore = 1<<(lhs.path.components.count * 2)// The score value of the current component - this goes up each time
        self.logger.debug("  Starting score delta \(nextScore)")

        // Go through each component of each identifier in turn.
        //
        // If the lhs one doesn't match, move on to the next.
        // If the rhs one doesn't match then abort and return 0.
        for lhsComponent in lhs.path.components {
            defer {
                // Each component in the lhs which matches is more important than the last one. Increase it's score to take that
                // into account
                nextScore /= 4
                self.logger.debug("  Next score delta \(nextScore)")
            }

            self.logger.debug("  Comparing '\(lhsComponent)' to '\(rhsComponent ?? "<nil>")'")

            // If the lhs doesn't match the rhs component, move on to the next one
            if lhsComponent.value != rhsComponent?.value {
                self.logger.debug("   └─ No match - moving on to next lhs component")
                continue
            }

            self.logger.debug("   └─ Value Match")

            // Increment the score
            // TODO: Make the score reflect the position of a match i.e. a atom match isn't worth as much as a section match
            score += nextScore/2
            self.logger.debug("   └─ Score now \(score)")

            // If neither side has a variant don't increment the score
            // If they both have the same variant, increment the score
            // If the variants are different, this isn't a match - abort
            switch (lhsComponent.variant, rhsComponent?.variant) {
            case (nil, nil):
                self.logger.debug("   └─ Variants not present")
            case (_, nil):
                self.logger.debug("   └─ Specific has variant, general doesn't care")
            case (let lhsVariant, let rhsVariant) where lhsVariant == rhsVariant:
                self.logger.debug("   └─ Variants Match")
                score += nextScore
                self.logger.debug("   └─ Score now \(score)")
            default:
                // If there are variants which don't match, this is a hard fail
                self.logger.debug("   └─ Values match, but variants don't match - abort")
                return 0
            }

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
