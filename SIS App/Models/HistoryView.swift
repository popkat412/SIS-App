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
    var iconName: String
    var text: String
    
    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .frame(width: 25, height: 25)
            
            Text(text)
                .multilineTextAlignment(.leading)
        }
    }
}

struct HistoryRow: View {
    var session: CheckInSession
    
    var body: some View {
        HStack {
            RowItem(iconName: "time", text: session.formattedTiming)
            
            RowItem(iconName: "block", text: RoomParentInfo.getParent(of: session.room))
            
            RowItem(iconName: "room", text: session.room.name)
        }
    }
}
