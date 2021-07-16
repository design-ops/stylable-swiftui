//
//  Stylist+create.swift
//  SwiftUIStylist_Example
//
//  Created by Sam Dean on 13/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

import StylableSwiftUI
import SwiftUI

extension Stylist {

    static func create(debugUnstyledViews: Bool = false) -> Stylist {
        let stylist = Stylist()

        if debugUnstyledViews {
            stylist.setDefaultStyle { $0.background(Color.green).opacity(0.5) }
        }

        stylist.addStyles([

            // MARK: Some global styles

            // Matches * / * / title
            Style("title") {
                $0.font(.title).foregroundColor(Color("Color"))
            },

            // Matches * / * / body
            Style("body") {
                $0.styleText { $0.kerning(5) }
                    .foregroundColor(.red)
            },

            Style("example/body") {
                $0.foregroundColor(.blue)
            },

            // MARK: Searchbar

            Style("searchbar/background") {
                $0.padding(8).background(searchBarBackground())
            },

            Style("searchbar/primarybutton/background") { button in
                button
                    .buttonStyle(SearchbarButtonStyle())
            },

            Style("searchbar/primarybutton/image", apply: Style.unstyled),

            Style("searchbar/tertiarybutton", apply: Style.unstyled),

            Style("searchbar/text") { text in
                text.font(Font.custom("Gill Sans", size: 14))
            },

            Style("searchbar/placeholdertext") { field in
                field.font(Font.custom("Gill Sans", size: 14)).foregroundColor(Color.gray.opacity(0.5))
            },

            Style("searchbar/secondarybutton/background") { button in
                button
                    .buttonStyle(SearchbarButtonStyle())
            },

            // MARK: List styles

            Style("styledlist/message") { $0.font(Font.custom("Gill Sans", size: 26)) },

            Style("styledlistitem/name") { $0.font(Font.custom("Gill Sans", size: 14)) }
        ])

        stylist.addStyle(identifier: "element/atom") {
            $0.foregroundColor(.red)
        }

        stylist.addStyle(identifier: "organism/atom") {
            $0.foregroundColor(.blue)
        }

        // Demonstrate changing the stylist on the fly
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            stylist.addStyles([
                Style("title") {
                    $0.font(.title).foregroundColor(.green)
                }
            ])
        }

        return stylist
    }

    private static func searchBarBackground() -> some View {
        GeometryReader { geometry in
            LinearGradient(gradient: Gradient(colors: [ Color(red: 0.95, green: 0.95, blue: 0.95),
                                                        Color(red: 0.9, green: 0.9, blue: 0.9) ]),
                           startPoint: .top,
                           endPoint: .bottom)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .path(in: CGRect(x: 0.5, y: 0.5, width: geometry.size.width-1, height: geometry.size.height-1))
                    .stroke(Color.gray, lineWidth: 1).opacity(0.25))
        }
    }

    /// An alternate stylist to demo multiple stylists in one app
    ///
    /// Also, cheekily show the function builder syntax to add styles
    static func createAlternate() -> Stylist {
        let stylist = Stylist()

        stylist.addStyles {

            Style("example/title") { $0.font(.title) }

            Style("example/title") { $0.font(.body) }

            Style("styledlist/list", apply: Style.unstyled)

            Style("styledlist/row", apply: Style.unstyled)

            Style("styledlist/message") { $0.font(Font.custom("AmericanTypewriter-Condensed", size: 26)).foregroundColor(.red) }

            Style("styledlistitem/name") { $0.font(Font.custom("AmericanTypewriter-Condensed", size: 14)).foregroundColor(.blue) }

            Style("searchbar/*/background") { button in
                button.background(ZStack {
                    Color.red.opacity(0.1)
                    Color.blue.opacity(0.2)
                    LinearGradient(gradient: Gradient(colors: [.red, .green]), startPoint: .top, endPoint: .bottom).opacity(0.3)
                })
            }

//            // ... or style using a StyleContainer ...
//            SearchBarStyle(background: searchBarBackground(),
//                           buttonStyle: SearchbarButtonStyle())
        }

        return stylist
    }
}

private struct SearchbarButtonStyle: PrimitiveButtonStyle {

    private static let lightGray = Color(red: 0.9, green: 0.9, blue: 0.9)
    private static let medGray = Color(red: 0.8, green: 0.8, blue: 0.8)
    private static let borderGray = Color(red: 0.7, green: 0.7, blue: 0.7)

    func makeBody(configuration: Self.Configuration) -> some View {
        let background = LinearGradient(gradient: Gradient(colors: [Self.lightGray, Self.medGray]), startPoint: .top, endPoint: .bottom)
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5)
                .offset(x: -0.5, y: -0.5)
                .stroke(Self.borderGray, lineWidth: 1), alignment: .center)

        return configuration.label
            .background(background)
    }
}
