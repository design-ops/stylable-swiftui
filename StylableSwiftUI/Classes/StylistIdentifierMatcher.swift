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
    /// With themes, things change a little. A style that matches like:
    ///
    /// matches("home/header/searchBar/label", "header/searchBar/label")
    ///
    /// is now *less* specific than a match that matches traditionally less specific but has the theme specifier:
    ///
    /// matches("home/header/searchBar/label", "@dark/searchBar/label")
    ///
    /// e.g. theme specifiers supply a higher score than any amount of matching on a path. Extreme example:
    ///
    /// matches("home/header/searchBar/label", "home/header/searchBar/label")
    /// matches("home/header/searchBar/label", "@dark/label") <- would be the matched style if the `@dark` theme is set.
    ///
    func match(specific lhs: StylistIdentifier, general rhs: StylistIdentifier, theme: Theme? = nil) -> Int {
        self.logger.debug("Attempting to match \(lhs) with \(rhs)")

        // Rules are:
        // - If the tokens are different, there is no match, return 0
        // - If RHS has a theme but there is no `theme`, there is no match, return 0
        // - If the theme in RHS is different than `theme`, there is no match, return 0
        // - If the LHS and RHS are both just tokens:
        //    - If there is no theme, it's a match (of just tokens), return 1
        //    - If there is a `theme`, and RHS.theme == `theme`, return 1 + the theme score
        //    - If there is a `theme` and RHS.theme != `theme`, there is no match, return 0
        // - If RHS is just a token:
        //    - If there is no theme, it's a match (of just tokens), return 1
        //    - If there is a `theme`, and RHS.theme == `theme`, return 1 + the theme score
        //    - If there is a `theme` and RHS.theme != `theme`, there is no match, return 0
        // - If LHS is just a token:
        //    - If RHS is more than just a token, no match, return 0
        //    - If there is a `theme`, and RHS.theme == `theme`, return 1 + the theme score
        //    - If there is a `theme` and RHS.theme != `theme`, there is no match, return 0

        guard lhs.token == rhs.token else { return 0 }

        // RHS has a theme, but there is no theme in the stylist, no match
        if rhs.theme != nil && theme == nil { return 0 }

        // If general has a theme and we are trying to match with a theme and they are not the same, this is not a match
        if rhs.theme != nil && theme != nil && rhs.theme != theme { return 0 }

        // Get the score of the theme
        let themeScore = 1<<((lhs.path.components.count + 1) * 2)

        // - If RHS is just a token:
        //    - If there is no theme, it's a match (of just tokens), return 1
        //    - If there is a `theme`, and RHS.theme == `theme`, return 1 + the theme score
        //    - If there is a `theme` and RHS.theme != `theme`, there is no match, return 0
        if rhs.path.components.isEmpty {
            if theme == nil {
                return 1
            } else if theme == rhs.theme {
                return 1 + themeScore
            } else { // rhs.theme and theme don't match, so there is no match
                return 0
            }
        }

        // - If LHS is just a token:
        //    - If RHS is more than just a token, no match, return 0
        //    - If there is a `theme`, and RHS.theme == `theme`, return 1 + the theme score
        //    - If there is a `theme` and RHS.theme != `theme`, there is no match, return 0
        if lhs.path.components.isEmpty {
            if !rhs.path.components.isEmpty {
                return 0
            }
            if theme != nil && theme == rhs.theme {
                return 1 + themeScore
            }
            if theme != nil && theme != rhs.theme {
               return 0
            }
        }

        // We are going to manually step over the rhs, so we will need an iterator
        var rhsIterator = rhs.path.components.makeIterator()
        var rhsComponent = rhsIterator.next()

        var score = 0 // The score we will return if it turns out to be a match
        var nextScore = 1<<(lhs.path.components.count * 2)// The score value of the current component - this goes up each time
        self.logger.debug("  Starting score delta \(nextScore)")

        // The theme score value is 1 more level than the maximum score you could potentially have if the identifiers
        // were identical. That way we guarantee that a match with a theme in any match will be higher than one without a theme
        if rhs.theme != nil && theme != nil && rhs.theme == theme {
            score += themeScore
        }

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
