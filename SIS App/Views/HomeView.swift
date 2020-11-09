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
    let blocks = DataProvider.getBlocks()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            MapView(userLocation: $userLocation)
                .edgesIgnoringSafeArea(.all)
            if (checkInManager.isCheckedIn) {
                CheckedInView()
            } else {
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
