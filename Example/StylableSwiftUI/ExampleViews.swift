//
//  ExampleViews.swift
//  SwiftUIStylist_Example
//
//  Created by Sam Dean on 13/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

import StylableSwiftUI

struct ExampleViews: View {

    var body: some View {
        VStack {
            StylableGroup("section") {
                WithStylistIdentifier(strings: "a", "b", "a/b") { identifier1, identifier2, identifier3 in
                    VStack {
                        Text(identifier1.description)
                        Text(identifier2.description)
                        Text(identifier3.description)
                    }
                }
                WithStylistIdentifier(identifiers: StylistIdentifier("hello/world"), StylistIdentifier("foo")) { identifier1, identifier2 in
                    VStack {
                        Text(identifier1.description)
                        Text(identifier2.description)
                    }
                }
            }
            StylableGroup("example") {
                Spacer()
                Text("Some Title").style("title") // example/title
                Text("Some body text").style("body") // example/body
            }
            Spacer().frame(height: 50)
            Text("Some more body text").style("body") // body
            Spacer()
            Text("This should be red").style("organism/element/atom")
        }
        .padding()
    }
}

struct ExampleViews_Preview: PreviewProvider {

    static var previews: some View {
        Group {
            ExampleViews()
                .environmentObject(Stylist.unstyled)
                .previewLayout(.fixed(width: 300, height: 300))
            ExampleViews()
                .environmentObject(Stylist.create())
                .previewLayout(.fixed(width: 300, height: 300))
                .environment(\.colorScheme, .dark)
            ExampleViews()
                .environmentObject(Stylist.create())
                .previewLayout(.fixed(width: 300, height: 300))
                .environment(\.colorScheme, .light)
            ExampleViews()
                .environmentObject(Stylist.createAlternate())
                .previewLayout(.fixed(width: 300, height: 300))
        }
    }
}
