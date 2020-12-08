//
//  ContentView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import BetterSafariView
import NotificationCenter
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
        TabView(selection: $navigationState.tabbarSelection) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(Tab.home)
            HistoryView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("History")
                }
                .tag(Tab.history)
        }
        .safariView(isPresented: $navigationState.shouldShowSafariView) {
            SafariView(url: Constants.riSafeEntryURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didEnterBlock)) { event in
            let block = (event.userInfo?[Constants.notificationCenterBlockUserInfo] as! Block)
            print("received did enter geofence: \(block.name)")

            if !checkInManager.isCheckedIn {
                UserNotificationHelper.sendNotification(
                    title: "Remember to check in!",
                    subtitle: "Please check in to \(block.name)"
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didExitBlock)) { event in
            let block = (event.userInfo?[Constants.notificationCenterBlockUserInfo] as! Block)

            print("received did exit geofence \(block.name)")

            if checkInManager.isCheckedIn {
                UserNotificationHelper.sendNotification(
                    title: "Remember to check out!",
                    subtitle: "Please check out of \(block.name)"
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didEnterSchool)) { _ in
            UserNotificationHelper.sendNotification(
                title: "Remember to check in!",
                subtitle: "Please check into the school via safe entry",
                withIdentifier: Constants.didEnterSchoolNotificationIdentifier
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .didExitSchool)) { _ in
            UserNotificationHelper.sendNotification(
                title: "Remember to check out!",
                subtitle: "Please check out of the school via safe entry",
                withIdentifier: Constants.didExitSchoolNotificationIdentifier
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let checkInManager = CheckInManager()

        return ContentView()
            .environmentObject(checkInManager)
            .environmentObject(UserLocationManager())
            .environmentObject(NavigationState())
    }
}
