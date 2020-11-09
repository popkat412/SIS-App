//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            .environmentObject(CheckInManager())
    }
}
