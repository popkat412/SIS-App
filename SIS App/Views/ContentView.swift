//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI
import UserNotifications
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
        .onReceive(NotificationCenter.default.publisher(for: .didEnterGeofence)) { event in
            print("received did exit geofence")
        }
        .onReceive(NotificationCenter.default.publisher(for: .didExitGeofence)) { event in
            print("received did exit geofence")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
