//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            MapView()
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                List {
                    Text("Raja Block")
                    Text("Shears Block")
                }
                .navigationBarTitle("Blocks", displayMode: .inline)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
