//
//  StyledListScreen.swift
//  SwiftUIStylist_Example
//
//  Created by Sam Dean on 17/01/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

import SwiftUI
import StylableSwiftUI

import Combine

struct StyledListItem: Identifiable {
    let id: String
    let name: String

    init(id: String? = nil, name: String) {
        self.id = id ?? name
        self.name = name
    }
}

class StyledListViewModel: ObservableObject {

    @Published var isLoading: Bool

    @Published var items: [StyledListItem]

    @Published var searchText: String = ""

    private var searchObserver: AnyCancellable!

    init() {
        self.items = []
        self.isLoading = true
        self.searchObserver = nil

        self.searchObserver = self.$searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { value in
                self.fetchItems(filterText: value)
        }
    }

    func fetchItems(filterText: String? = nil) {
        self.isLoading = true

        let filter: (StyledListItem) -> Bool
        if let filterText = filterText?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !filterText.isEmpty {
            filter = { $0.name.lowercased().contains(filterText) }
        } else {
            filter = { _ in true }
        }

        // NB This is where networking would go in a real app
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.items = nameList
                .map { StyledListItem(name: $0) }
                .filter(filter)
                .sorted { $0.name < $1.name }

            self.isLoading = false
        }
    }
}

struct StyledListScreen: View {

    @EnvironmentObject var viewModel: StyledListViewModel

    var body: some View {
        StylableGroup("styledlist") {
            VStack(spacing: 0) {
                HStack {
                    SearchBar(text: self.$viewModel.searchText)
                }.padding(.horizontal)

                if self.viewModel.isLoading {
                    Group {
                        Spacer()
                        Text("Loading")
                            .style("message")
                        Spacer()
                    }
                } else if self.viewModel.items.count == 0 {
                    Group {
                        Spacer()
                        Text("No Results Found")
                            .style("message")
                        Spacer()
                    }
                } else {
                    List(self.viewModel.items) {
                        StyledListRow(name: $0.name).style("row")
                    }.style("list")
                }
            }.onAppear {
                self.viewModel.fetchItems()
            }
        }
    }
}

struct StyledListRow: View {

    let name: String

    var body: some View {
        Text(self.name)
            .style("styledlistitem/name")
    }
}

struct StyledList_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            Group {
                StyledListRow(name: "Bob")
                    .previewLayout(.fixed(width: 320, height: 60))

                StyledListScreen()
            }
            .environmentObject(Stylist.create())

            Group {
                StyledListScreen()
            }
            .environmentObject(Stylist.createAlternate())
        }
        .environmentObject(StyledListViewModel())
    }
}

private let nameList: [String] = [
    "Ehsan Donovan",
    "Kimberly Reeves",
    "Honey Fox",
    "Kamron Shah",
    "Hamaad Kinney",
    "Ayaz Charles",
    "Ralphy Glass",
    "Tanisha Hubbard",
    "Rhiana Lowery",
    "Shona Haney",
    "Dylan Flynn",
    "Harun Holden",
    "Rudi Costa",
    "Gilbert Penn",
    "Colton Arroyo",
    "Kalum Bonner",
    "Evie-Mai Ramirez",
    "Mikail Johns",
    "Toni Melton",
    "Tracy Rangel",
    "Nayan Ashton",
    "Monty Robles",
    "Albie Bravo",
    "Mahir Suarez",
    "Elif Gilmore",
    "Roy Slater",
    "Christine Cornish",
    "Tess Cruz",
    "Barnaby Delgado",
    "Jozef Pratt",
    "Sullivan Merritt",
    "Jagdeep Contreras",
    "Marguerite Palmer",
    "Jules Stein",
    "Tulisa Vinson",
    "Carol Buchanan",
    "Saad Morin",
    "Gurveer Beltran",
    "Elleanor Molina",
    "Antoinette Webber",
    "Lukas Bauer",
    "Shayne Muir",
    "Lilly-May Head",
    "Kaylie Weiss",
    "Jace Wagstaff",
    "Holli Harding",
    "Mehak Espinoza",
    "Allan Grimes",
    "Aiden Chadwick",
    "Saoirse Rowe"
]
