//
//  HomeView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import CoreLocation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @EnvironmentObject var userLocationManager: UserLocationManager
    @EnvironmentObject var userAuthManager: UserAuthManager

    @State private var alertItem: AlertItem?
    @State private var showingActivityIndicator: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    MapView()
                        .edgesIgnoringSafeArea(.all)
                    if checkInManager.showCheckedInScreen {
                        CheckedInView()
                    } else {
                        ChooseRoomView { room in
                            print("normal checking into room: \(room)")
                            checkInManager.checkIn(to: room)
                        }
                    }
                }
                if showingActivityIndicator {
                    MyActivityIndicator()
                        .frame(width: Constants.activityIndicatorSize, height: Constants.activityIndicatorSize)
                }
            }
            .navigationBarItems(
                leading: Button("Sign out") {
                    print("sign out button pressed")
                    showingActivityIndicator = true
                    userAuthManager.signOut { error in
                        alertItem = MyErrorInfo(error).toAlertItem {
                            showingActivityIndicator = false
                        }
                    }
                }
            )
            .navigationBarTitle("RI Tracing")
            .alert(item: $alertItem, content: alertItemBuilder)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
            showingActivityIndicator = false
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let checkInManager = CheckInManager()
        return HomeView()
            .environmentObject(checkInManager)
            .environmentObject(UserLocationManager())
    }
}
