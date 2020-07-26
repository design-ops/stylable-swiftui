//
//  StylableImage.swift
//

import Foundation
import SwiftUI
import UIKit

public struct StylableImage: View {

    public static let defaultWildcard = "*"
    public static let defaultSeparator = "_"
    public static let defaultMaxLength = 6

    private let identifier: StylistIdentifier
    private let factory: (StylistIdentifier) -> Image

    @Environment(\.currentStylableGroup) var currentStylableGroup

    private init(_ identifier: StylistIdentifier, factory: @escaping (StylistIdentifier) -> Image) {
        self.identifier = identifier
        self.factory = factory
    }

    public init(_ identifier: StylistIdentifier, wildcard: String = defaultWildcard, separator: String = defaultSeparator, maxLength: Int = defaultMaxLength, bundle: Bundle? = nil) {
        self.identifier = identifier
        self.factory = { identifier in Image(identifier: identifier, wildcard: wildcard, separator: separator, maxLength: maxLength, bundle: bundle) }
    }

    public var body: some View {
        self.factory(self.identifier.within(self.currentStylableGroup))
    }

    // MARK: - Wrapped Image methods

    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0).renderingMode(renderingMode) }
    }

    public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0).resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    public func interpolation(_ interpolation: Image.Interpolation) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0).interpolation(interpolation) }
    }

    public func antialiased(_ isAntialiased: Bool) -> StylableImage {
        StylableImage(self.identifier) { self.factory($0).antialiased(isAntialiased) }
    }
}

extension Image {

    /// Creates an `Image` using the stylist identifier.
    ///
    /// This method attempts the most specific image name first. i.e. `section/element/atom` would try
    /// `section_element_atom` then `*_element_atom` then `section_*_atom`, finally `*_*_atom`.
    ///
    /// - parameter identifier: The StylistIdentifier to use when attempting to find/load an image
    /// - parameter wildcard: _(optional)_ The wildcard character to use when replacing component names (defaults to `*`)
    /// - parameter separator: _(optional)_ The character to use when joining the components together to create the resource name (defaults to `_`)
    /// - parameter bundle: _(optional)_ The bundle to search for the image (defaults to the main bundle)
    ///
    init(identifier: StylistIdentifier,
         wildcard: String = StylableImage.defaultWildcard,
         separator: String = StylableImage.defaultSeparator,
         maxLength: Int = StylableImage.defaultMaxLength,
         bundle: Bundle? = nil) {

        // Get all the name variants
        let variants = identifier.potentialImageNames(wildcard: wildcard, separator: separator, maxLength: maxLength)

        // Use the first variant which is in the bundle
        let name = variants.lazy.first { UIImage(named: $0, in: bundle, compatibleWith: nil) != nil }

        if name == nil {
            Logger.default.log("No image found for \(identifier), including checking with prefix \(wildcard) to depth \(maxLength)", level: .error)
        }

        // Return it, or a dummy image view
        self = name.map { Image($0, bundle: bundle) } ?? Image(identifier.description)
    }
}

extension StylistIdentifier {

    /// All the possible names for a image based on this identifier
    func potentialImageNames(wildcard: String = StylableImage.defaultWildcard,
                             separator: String = StylableImage.defaultSeparator,
                             maxLength: Int = StylableImage.defaultMaxLength) -> AnySequence<String> {

        var components = Array(self.path.components.reversed())
        components.append(Component(value: self.token, state: nil))
        let options = VariantSequence(from: components, wildcard: wildcard, maxLength: maxLength)
        return AnySequence(options.lazy.map { $0.joined(separator: separator) })
    }
}

struct VariantSequence: Sequence, IteratorProtocol {

    private let base: [StylistIdentifier.Component]
    private let wildcard: String
    private let maxLength: Int

    private let quickSkipBitmask: Int

    private var combinationNumber = 0
    private let combinationCount: Int

    private var variants: [[String]] = []
    private var shortened: [[String]]? = nil
    private var shortenedIndex = 0
    private var lengthened: [[String]]? = nil
    private var lengthenedIndex = 0

    init(from base: [StylistIdentifier.Component], wildcard: String = "*", maxLength: Int = 6) {
        self.base = base
        self.wildcard = wildcard
        self.maxLength = maxLength

        // We can work out the max number of possible variants - it's 2 ^ (count*2)
        // Why *2? beacuse each component has 4 possible options by combining value and state (a[b], a[*], *[b] and *[*])
        // Why -1? Beacuse we don't touch the atom
        self.combinationCount = self.base.isEmpty ? 0 : NSDecimalNumber(decimal: pow(2, (self.base.count-1)*2)).intValue

        // The quick-skip bitmask will let us skip variants which aren't any different i.e. where the value or state will be set to *, _but are already *_
        // Any combination number with bits set in this maks can be safely skipped without testing.
        var mask = 0
        for bit in 0..<(self.base.count*2)-2 {
            let component = self.base[Int(bit/2)]
            if Self.isBitRepresentingValue(bit) {
                if component.value == wildcard {
                    mask += 1 << bit
                }
            } else {
                if component.variant == nil {
                    mask += 1 << bit
                }
            }
        }
        Logger.default.log("Mask calculated as", String(format: "%X", mask), level: .debug)
        self.quickSkipBitmask = mask
    }

    mutating func next() -> [String]? {

        // Are we still creating our original variants?
        if let variant = self.nextVariant() {
            self.variants.append(variant)
            return variant
        }

        // OK, now we return a collection of the shortened versions of original
        // We might need to create these first :)
        if self.shortened == nil {
            self.shortened = self.variants.flatMap { $0.trimmed(replacing: self.wildcard) }
        }

        // If there are shortened values, return them one by one
        if let shortened = self.shortened, self.shortenedIndex < shortened.count {
            let short = shortened[self.shortenedIndex]
            self.shortenedIndex += 1
            return short
        }

        // Finally, we return the lengthened versions
        // We might need to create these first :)
        if lengthened == nil {
            self.lengthened = []
            let originalLength = self.base.count
            if originalLength < maxLength {
                (0..<maxLength-originalLength).forEach {
                    self.lengthened! += self.variants.leftPad(with: self.wildcard, count: $0+1)
                }
            }
        }

        // Return each lengthened value in turn
        if let lengthened = self.lengthened, self.lengthenedIndex < lengthened.count {
            let length = lengthened[self.lengthenedIndex]
            self.lengthenedIndex += 1
            return length
        }

        return nil
    }

    /// Returns a variation of the initial base array.
    private mutating func nextVariant() -> [String]? {
        var variant: [String]? = nil

        while(variant == nil) {

            if combinationNumber >= combinationCount { return nil }

//            if combinationNumber % 100 == 0 {
//                print("variant", combinationNumber, "out of", combinationCount)
//            }

            // If the only bits set are bits in the quick skip mask then we don't need to do any actual flipping, it will definitely be one we will make with
            // another combinationNumber
            if (combinationNumber & self.quickSkipBitmask != 0) {
                combinationNumber += 1
                continue
            }

            // Make a mutable copy of the original components array
            var o = self.base

            Logger.default.log("total component count", self.base.count, ", bits to iterate over", (self.base.count*2)-2,
                               level: .debug)

            for index in 0..<(self.base.count*2)-2 {
                // Get the component we are going to work on - this is index/2 truncated i.e
                // index   component #
                //  0       0
                //  1       0
                //  2       1
                //  3       1
                let affectedIndex = Int(index/2)
                let component = o[affectedIndex]
                var value = component.value
                var state = component.variant

                // Each component is represented by 2 bits, the first represents replacing the value with *, and the second represents replacing the state with *

                // Is the bit set?
                if combinationNumber & (1 << index) > 0 {
                    // Should this bit affect the value (i.e not a multiple of 2) or affect the state (i.e. a multiple of 2)
                    // NB If this index is setting a state or value which is already a wildcard then we don't need to carry on - it's already been added from when this bit was not set.
                    if Self.isBitRepresentingValue(index) {
                        value = self.wildcard
                    } else {
                        state = nil
                    }
                }

                Logger.default.log(affectedIndex, index, combinationNumber & (1 << index) > 0 ? "(set)" : "(not set)", component, "->", StylistIdentifier.Component(value: value, state: state),
                                   level: .debug)

                o[affectedIndex] = StylistIdentifier.Component(value: value, state: state)
            }

            combinationNumber += 1

            let thisVariant = o.map { $0.description }

            variant = thisVariant
        }

        return variant
    }

    // true if a bit set at this index represents a component's value, false if it represents state
    private static func isBitRepresentingValue(_ index: Int) -> Bool {
        return index % 2 != 0
    }
}

extension Sequence {

    func leftPad<E>(with prefix: E, count: Int = 1) -> [Element] where Element == [E] {
        self.map { repeatElement(prefix, count: count) + $0 }
    }
}

extension Sequence where Element: Equatable {

    /// Returns versions of this collection created by trimming _n_ `replacement` from the start of the sequence.
    ///
    /// i.e. [ *, *, c, d ] would return [ [ *, c, d ], [ c, d ] ]
    ///
    /// - parameter replacing: The value to check for, and trim from the start of `self`
    /// - returns: An array of versions of `self` where the first matching elements have been removed one by one.
    ///
    func trimmed(replacing: Element) -> [[Element]] {
        var trimmed = [[Element]]()

        var candidate = Array(self)
        while candidate.first == replacing {
            candidate = Array(candidate.dropFirst())
            trimmed.append(candidate)
        }

        return trimmed
    }
}

/*
 a/b/c

 2 bits per component
 first bit is value
 second bit is state

 possible values = 2^((3-1)*2) = 16
  NB: 3-1 is the number of components, minus 1 beacuse we don't touch the atom

 The number of affected bits is (component-count * 2) - 2 = 3*2 - 2 = 6 - 2 = 4

 0 0    0 0
 a[a] / b[b] / c[c]

 1 0    0 0
 a[*] / b[b] / c[c]

 0 1    0 0
 *[a] / b[b] / c[c]

 1 1    0 0
 *[*] / b[b] / c[c]

 0 0    1 0
 a[a] / b[*] / c[c]

 1 0    1 0
 a[*] / b[*] / c[c]

 0 1    1 0
 *[a] / b[*] / c[c]

 1 1    1 0
 *[*] / b[*] / c[c]

 0 0    0 1
 a[a] / *[b] / c[c]

 1 0    0 1
 a[*] / *[b] / c[c]

 0 1    0 1
 *[a] / *[b] / c[c]

 1 1    0 1
 *[*] / *[b] / c[c]

 0 0    1 1
 a[a] / *[*] / c[c]

 1 0    1 1
 a[*] / *[*] / c[c]

 0 1    1 1
 *[a] / *[*] / c[c]

 1 1    1 1
 *[*] / *[*] / c[c]

 */

/// Given this pathalogical style identifier:
///
/// customer/searchbar[disabled]/primaryToggle[on]/close

/// These must match it:

/// customer/searchbar[disabled]/primaryToggle[on]/close

/// */searchbar[disabled]/primaryToggle[on]/close
///   searchbar[disabled]/primaryToggle[on]/close

/// customer/searchbar/primaryToggle[on]/close
/// customer/*[disabled]/primaryToggle[on]/close
/// customer/*/primaryToggle[on]/close

/// */searchbar/primaryToggle[on]/close
/// */*[disabled]/primaryToggle[on]/close
/// */*/primaryToggle[on]/close

///   searchbar/primaryToggle[on]/close
///   *[disabled]/primaryToggle[on]/close
///   */primaryToggle[on]/close

///     primaryToggle[on]/close

/// customer/searchbar[disabled]/primaryToggle/close
/// customer/searchbar[disabled]/*[on]/close
/// customer/searchbar[disabled]/*/close

/// customer/searchbar/primaryToggle/close
/// customer/searchbar/*[on]/close
/// customer/searchbar/*/close

/// customer/*[disabled]/primaryToggle/close
/// customer/*[disabled]/*[on]/close
/// customer/*[disabled]/*/close

/// customer/*/primaryToggle/close
/// customer/*/*[on]/close
/// customer/*/*/close

/// */searchbar[disabled]/primaryToggle/close
/// */searchbar[disabled]/*[on]/close
/// */searchbar[disabled]/*/close

/// */searchbar/primaryToggle/close
/// */searchbar/*[on]/close
/// */searchbar/*/close

/// */*[disabled]/primaryToggle/close
/// */*[disabled]/*[on]/close
/// */*[disabled]/*/close

/// */*/primaryToggle/close
/// */*/*[on]/close
/// */*/*/close

/// */*/*/*
