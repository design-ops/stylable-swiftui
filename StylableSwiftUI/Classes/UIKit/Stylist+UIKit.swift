//
//  Stylist+UIKit.swift
//  StylableSwiftUI
//
//  Created by Kerr Marin Miller on 01/09/2020.
//

import UIKit

public enum TextCase {
    case none
    case uppercase
    case lowercase
}

public enum StylistProperty {
    case backgroundColor(UIColor)
    case textColor(UIColor)
    case kerning(Double)
    case font(UIFont)
    case textCase(TextCase)
}

extension Array where Iterator.Element == StylistProperty {
    func firstBackgroundColor() -> UIColor? {
        return self.compactMap { prop in
            switch prop {
            case .backgroundColor(let color):
                return color
            default:
                return nil
            }
        }.first
    }

    func firstTextColor() -> UIColor? {
        return self.compactMap { prop in
            switch prop {
            case .textColor(let color):
                return color
            default:
                return nil
            }
        }.first
    }

    func firstKerning() -> Double? {
        return self.compactMap { prop in
            switch prop {
            case .kerning(let kerning):
                return kerning
            default:
                return nil
            }
        }.first
    }

    func firstFont() -> UIFont? {
        return self.compactMap { prop in
            switch prop {
            case .font(let font):
                return font
            default:
                return nil
            }
        }.first
    }

    func firstTextCase() -> TextCase? {
        return self.compactMap { prop in
            switch prop {
            case .textCase(let textCase):
                return textCase
            default:
                return nil
            }
        }.first
    }
}
