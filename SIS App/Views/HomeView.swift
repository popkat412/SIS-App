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

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    @State private var alertItem: AlertItem?
    @State private var showingActivityIndicator: Bool = false

    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                ZStack {
                    if (verticalSizeClass ?? .regular) == .compact {
                        HStack(alignment: .center, spacing: 0) { makeContent(proxy, shouldUseFrame: false) }
                    } else {
                        VStack(alignment: .center, spacing: 0) { makeContent(proxy) }
                    }
                    if showingActivityIndicator {
                        MyActivityIndicator()
                            .frame(width: Constants.activityIndicatorSize, height: Constants.activityIndicatorSize)
                    }
                }
                .navigationBarTitle(Constants.appName, displayMode: .inline)
                .alert(item: $alertItem, content: alertItemBuilder)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onDisappear {
                showingActivityIndicator = false
            }
        }
    }

    private func makeContent(_ proxy: GeometryProxy, shouldUseFrame: Bool = true) -> some View {
        Group {
            MapView()
                .edgesIgnoringSafeArea(.all)
            Group {
                if checkInManager.showCheckedInScreen {
                    CheckedInView()
                } else {
                    ChooseRoomView { target in
                        print("normal checking into target: \(target)")
                        checkInManager.checkIn(to: target)
                    }
                }
            }
            .conditionalModifier(shouldUseFrame) {
                $0.frame(height: proxy.size.height * (3 / 5))
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CheckInManager())
            .environmentObject(UserLocationManager())
    }
}
