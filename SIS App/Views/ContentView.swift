//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import SwiftUI

struct ContentView: View {
    let blocks = blocksFromJson()!
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            MapView()
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                List(blocks, id: \.name) { block in
                    NavigationLink(
                        destination: CategoriesView(categories: block.categories.toDictionary())) {
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
