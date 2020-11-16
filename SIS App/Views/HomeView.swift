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
    @EnvironmentObject var userLocationManager: UserLocationManager
    
    var body: some View {
        print("rebuilding home: \(checkInManager.isCheckedIn), \(checkInManager.showCheckedInScreen)")
        return VStack(alignment: .center, spacing: 0) {
            MapView()
                .edgesIgnoringSafeArea(.all)
            if (checkInManager.showCheckedInScreen) {
                CheckedInView()
            } else {
                ChooseRoomView()
                    .environment(\.onRoomSelection) { room in
                        print("normal checking into room: \(room)")
                        checkInManager.checkIn(to: room)
                    }
            }
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
