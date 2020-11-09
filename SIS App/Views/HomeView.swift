//
//  HomeView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @State private var userLocation = CLLocation()
    @State private var showingSearch = false
    
    let blocks = DataProvider.getBlocks()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            MapView(userLocation: $userLocation)
                .edgesIgnoringSafeArea(.all)
            if (checkInManager.isCheckedIn) {
                CheckedInView()
            } else {
                Button(action: {
                    showingSearch = true
                }, label: {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Search")
                    }
                    .padding(.vertical, 10)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(white: 0.8))
                    .cornerRadius(15)
                    .padding()
                })
                .buttonStyle(PlainButtonStyle())
                NavigationView {
                    List(blocks.sorted(by: { (block1, block2) -> Bool in
                        let dist1 = userLocation.distance(from: block1.location.toCLLocation()) - block1.radius
                        let dist2 = userLocation.distance(from: block2.location.toCLLocation()) - block2.radius
                        
                        return dist1 < dist2
                    }), id: \.name) { block in
                        NavigationLink(
                            destination: CategoriesView(
                                categories: block.categories,
                                blockName: block.name
                            )) {
                            Text(block.name)
                        }
                    }
                    .navigationBarTitle("Blocks", displayMode: .inline)
                    .sheet(isPresented: $showingSearch) {
                        SearchView(showingSearch: $showingSearch)
                    }
                }
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CheckInManager())
    }
}
