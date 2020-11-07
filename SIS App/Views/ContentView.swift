//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var userLocation = CLLocation()
    let blocks = blocksFromJson()!
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            MapView(userLocation: $userLocation)
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                List(blocks.sorted(by: { (block1, block2) -> Bool in
                    let dist1 = userLocation.distance(from: block1.location.toCLLocation()) - block1.radius
                    let dist2 = userLocation.distance(from: block2.location.toCLLocation()) - block2.radius
                    
                    return dist1 < dist2
                }), id: \.name) { block in
                    NavigationLink(
                        destination: CategoriesView(
                            categories: block.categories.toDictionary(),
                            blockName: block.name
                        )) {
                            Text(block.name)
                        }
                }
                .navigationBarTitle("Blocks", displayMode: .inline)
            }
        }
    }
    
    private static func blocksFromJson() -> [Block]? {
        if let filepath = Bundle.main.path(forResource: "data.json", ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)

                if let contentsData = contents.data(using: .utf8) {
                    let result = try JSONDecoder().decode([Block].self, from: contentsData)
                    return result
                }

            } catch {
                print(error)

            }
        } else {
            print("data.json not found :O")
        }
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
