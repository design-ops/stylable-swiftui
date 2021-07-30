//
//  ThemedView.swift
//  StylableSwiftUI_Example
//
//  Created by Kerr Marin Miller on 30/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import StylableSwiftUI

struct ThemedView: View {

    @EnvironmentObject private var stylist: Stylist

    var body: some View {
        VStack(spacing: 20) {
            Text("Change the theme!").style("title")
            Button {
                if self.stylist.currentTheme?.name == "dark" {
                    self.stylist.currentTheme = nil
                } else {
                    self.stylist.currentTheme = Theme(name: "dark")
                }
            } label: {
                Text("Change theme").style("body")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .style("background")
    }
}

struct ThemedView_Previews: PreviewProvider {
    static var previews: some View {
        ThemedView()
    }
}
