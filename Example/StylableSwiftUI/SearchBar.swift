//
//  ExampleStylableView.swift
//  SwiftUIStylist_Example
//
//  Created by Sam Dean on 16/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

import StylableSwiftUI
import SwiftUI

extension LocalizedStringKey {

    static let searchBarPlaceholder: LocalizedStringKey = "searchbar.placeholder"
}

struct SearchBar: View {

    // MARK: - Properties

    @Binding var text: String

    private let searchAction: () -> Void
    private let scanAction: (() -> Void)?

    // MARK: - Initialization

    init(text: Binding<String>, searchAction: @escaping () -> Void = { }, scanAction: (() -> Void)? = nil) {
        self._text = text

        self.searchAction = searchAction
        self.scanAction = scanAction
    }

    // MARK: - body

    var body: some View {
        StylableGroup("searchbar") {
            HStack {
                self.generateButton(groupIdentifier: "primarybutton", action: self.searchAction)

                HStack {
                    ZStack(alignment: .leading) {
                        if self.text.isEmpty {
                            Text(.searchBarPlaceholder)
                                .style("placeholdertext")
                        }
                        TextField("", text: self.$text)
                            .lineLimit(1)
                            .style("text")
                    }

                    if !self.text.isEmpty {
                        StylableGroup("tertiarybutton") {
                            Button(action: { self.text = "" }) {
                                StylableImage("close")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .style("image")
                            }
                            .frame(width: 22, height: 22)
                            .style("background")
                        }
                    }
                }

                if self.scanAction != nil {
                    self.generateButton(groupIdentifier: "secondarybutton", action: self.scanAction!)
                }
            }
            .layoutPriority(1)
            .style("background")
        }
    }

    /// Creates a button with an image inside. Use this to make sure the scan and search buttons are the same layout.
    private func generateButton(groupIdentifier: StylistIdentifier.Path, action: @escaping () -> Void) -> some View {
        StylableGroup(groupIdentifier) {
            Button(action: { action() }) {
                HStack {
                    StylableImage("image")
                        .resizable()
                        .style("image")
                }.padding(3)
            }
            .frame(width: 22, height: 22)
            .style("background")
        }
    }
}

// MARK: - Preview

struct SearchBar_Preview: PreviewProvider {

    static let stylist = Stylist.create()

    static var previews: some View {
        Group {
            VStack {
                SearchBar(text: .constant("Term"))
            }
            .padding()
            .previewDisplayName("Search bar without scan")

            VStack {
                SearchBar(text: .constant("Term"), scanAction: { print("Scan tapped") })
            }
            .padding()
            .previewDisplayName("Search bar with scan")

            VStack {
                SearchBar(text: .constant(""))
            }
            .padding()
            .previewDisplayName("Search bar with no text")
        }
        .environmentObject(Self.stylist)
        .previewLayout(.fixed(width: 300, height: 120))
    }
}

// MARK: - Example StyleContainer

/// Style an ExampleStylableView without manually specifying all the styles and identifiers
/// when creating the stylist.
struct SearchBarStyle: StyleContainer {

    let styles: [Style]

    init<B: View>(background: B) {
        self.init(background: background, buttonStyle: PlainButtonStyle())
    }

    init<B: View, S: PrimitiveButtonStyle>(background: B,
                                           buttonStyle: S,
                                           font: Font = Font.custom("Gill Sans", size: 14),
                                           textColor: Color = .black,
                                           placeholderTextColor: Color = .gray,
                                           padding: CGFloat = 8) {
        self.styles = [
            Style("searchbar/background") {
                $0.padding(padding).background(background)
            },

            Style("searchbar/primarybutton/background") { button in
                button.buttonStyle(buttonStyle)
            },

            Style("searchbar/secondarybutton/background") { button in
                button.buttonStyle(buttonStyle)
            },

            Style("searchbar/text") { field in
                field.font(font).foregroundColor(textColor)
            },

            Style("searchbar/placeholdertext") { field in
                field.font(font).foregroundColor(placeholderTextColor)
            }
        ]
    }

    /// Helper to produce a completely unstyled search bar style
    static let unstyled: SearchBarStyle = SearchBarStyle()

    private init() {
        self.styles = []
    }
}
