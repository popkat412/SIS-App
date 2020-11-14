//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI
import NotificationCenter

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
        .onReceive(NotificationCenter.default.publisher(for: .didEnterBlock)) { event in
            print("received did enter geofence: \((event.userInfo?["block"] as! Block).name )")
        }
        .onReceive(NotificationCenter.default.publisher(for: .didExitBlock)) { event in
            print("received did exit geofence \((event.userInfo?["block"] as! Block).name )")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
