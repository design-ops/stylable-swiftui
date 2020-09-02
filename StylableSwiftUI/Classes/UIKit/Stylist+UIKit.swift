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
    case textColor(UIColor)
    case kerning(Double)
    case font(UIFont)
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

    func getFirstTextColor() -> UIColor? {
        return self.compactMap { prop in
            switch prop {
            case .textColor(let color):
                return color
            default:
                return nil
            }
        }.first
    }

    func getFirstKerning() -> Double? {
        return self.compactMap { prop in
            switch prop {
            case .kerning(let kerning):
                return kerning
            default:
                return nil
            }
        }.first
    }

    func getFirstFont() -> UIFont? {
        return self.compactMap { prop in
            switch prop {
            case .font(let font):
                return font
            default:
                return nil
            }
        }.first
    }

}
