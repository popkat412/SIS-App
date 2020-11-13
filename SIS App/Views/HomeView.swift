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
        VStack(alignment: .center, spacing: 0) {
            MapView()
                .edgesIgnoringSafeArea(.all)
            if (checkInManager.isCheckedIn) {
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
        HomeView()
            .environmentObject(CheckInManager())
            .environmentObject(UserLocationManager())
    }
}
