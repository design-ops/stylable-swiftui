//
//  Stylist+UIKit.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 01/09/2020.
//

import Foundation

public struct Property {

    let identifier: StylistIdentifier
    let properties: [StylistProperty]

    public init(_ identifier: StylistIdentifier, properties: [StylistProperty]) {
        self.identifier = identifier
        self.properties = properties
    }
}

public enum StylistProperty {
    case backgroundColor(UIColor)
}

extension Array where Iterator.Element == StylistProperty {
    func getFirstBackgroundColor() -> UIColor? {
        return self.compactMap { prop in
            switch prop {
            case .backgroundColor(let color):
                return color
            default:
                return nil
            }
        }.first
    }
}
