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

    let blocks = DataProvider.getBlocks()

    var body: some View {
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
                .background(Color(white: 0.8))
                .cornerRadius(15)
                .padding()
            })
                .buttonStyle(PlainButtonStyle())
        }
        NavigationView {
            List(blocks.sorted(by: { (block1, block2) -> Bool in
                // If location avaliable, sort by distance to nearest block
                if let dist1 = userLocationManager.userLocation?.distance(from: block1.location.toCLLocation()),
                   let dist2 = userLocationManager.userLocation?.distance(from: block2.location.toCLLocation())
                {
                    return dist1 - block1.radius < dist2 - block2.radius
                }

                // Else sort by name
                return block1.name < block2.name
            }), id: \.name) { block in
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
