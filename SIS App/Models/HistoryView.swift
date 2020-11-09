//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    var body: some View {
        List {
            ForEach(checkInManager.getCheckInSessions()) { day in
                Section(header: Text("\(day.formattedDate)")) {
                    ForEach(day.sessions) { session in
                        HistoryRow(session: session)
                    }
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}


struct RowItem: View {
    var icon: Image
    var text: String
    
    var body: some View {
        HStack {
            icon
            Text(text)
                .multilineTextAlignment(.leading)
        }
    }
}

struct HistoryRow: View {
    var session: CheckInSession
    
    var body: some View {
        HStack {
            RowItem(icon: Image(systemName: "clock"), text: session.formattedTiming)
            
            RowItem(icon: Image(systemName: "house"), text: RoomParentInfo.getParent(of: session.room))
            
            RowItem(icon: Image(systemName: "house"), text: session.room.name)
        }
    }
}
