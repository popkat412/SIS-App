//
//  ChooseRoomView.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import CoreLocation
import SwiftUI

struct ChooseRoomView: View {
    @EnvironmentObject var userLocationManager: UserLocationManager
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @State var showingSearch = false

    var onBackButtonPressed: (() -> Void)?
    var onTargetSelection: OnTargetSelection

    init(
        onRoomSelection: @escaping OnTargetSelection,
        onBackButtonPressed: (() -> Void)? = nil
    ) {
        self.onBackButtonPressed = onBackButtonPressed
        onTargetSelection = onRoomSelection
    }

    var body: some View {
        VStack {
            HStack {
                if onBackButtonPressed != nil {
                    Button("Back") {
                        onBackButtonPressed!()
                    }
                    .padding(.leading)
                }
                Button(action: {
                    showingSearch = true
                }, label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .padding(.vertical, 10)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(colorScheme == .light ? Color(white: 0.8) : Color(white: 0.2))
                    .cornerRadius(15)
                    .padding()
                })
                    .buttonStyle(PlainButtonStyle())
            }
            NavigationView {
                List(DataProvider.getBlocks(userLocation: userLocationManager.userLocation), id: \.name) { block in
                    BlockListItem(block)
                }
                .listStyle(InsetListStyle())
                .navigationBarTitle("Blocks", displayMode: .inline)
            }
//            .navigationViewStyle(StackNavigationViewStyle())
        }
        .environment(\.onTargetSelection) { target in
            onTargetSelection(target)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(showingSearch: $showingSearch)
        }
    }

    private struct BlockListItem: View {
        var block: Block
        @Environment(\.onTargetSelection) var onTargetSelection: OnTargetSelection

        init(_ block: Block) { self.block = block }

        var body: some View {
            if block.categories.isEmpty { // directly check in
                Button(block.name) {
                    onTargetSelection(block)
                }
            } else if block.categories.count == 1 { // link directly to rooms view
                NavigationLink(
                    block.name,
                    destination: RoomsView(
                        rooms: block.categories.first!.value,
                        categoryName: block.name
                    )
                )
            } else { // normally link to categories view
                NavigationLink(
                    block.name,
                    destination: CategoriesView(
                        categories: block.categories,
                        blockName: block.name
                    )
                )
            }
        }
    }
}

struct ChooseRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRoomView { _ in }
            .environmentObject(UserLocationManager())
    }
}
