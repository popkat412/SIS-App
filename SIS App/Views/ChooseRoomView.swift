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
    var onRoomSelection: (Room) -> Void

    init(
        onRoomSelection: @escaping ((Room) -> Void),
        onBackButtonPressed: (() -> Void)? = nil
    ) {
        self.onBackButtonPressed = onBackButtonPressed
        self.onRoomSelection = onRoomSelection
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
                    NavigationLink(
                        destination: CategoriesView(
                            categories: block.categories,
                            blockName: block.name
                        )
                    ) {
                        Text(block.name)
                    }
                }
                .listStyle(InsetListStyle())
                .navigationBarTitle("Blocks", displayMode: .inline)
            }
//            .navigationViewStyle(StackNavigationViewStyle())
        }
        .environment(\.onRoomSelection) { room in
            onRoomSelection(room)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(showingSearch: $showingSearch)
        }
    }
}

struct ChooseRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRoomView { _ in }
            .environmentObject(UserLocationManager())
    }
}
