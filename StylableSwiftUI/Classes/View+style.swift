//
//  View+style.swift
//

import Foundation
import SwiftUI

extension View {

    /// Pass in an identifier to style this view using the stylist found in the environment
    ///
    /// - parameter identifier: A StylistIdentifier used to identify styles which should be applied to this view. Passing in `nil` will use `*`
    ///                         as the idenifier.
    public func style(_ identifier: StylistIdentifier? = nil) -> some View {
        return Stylable(self, identifier: identifier ?? "*")
    }
}
