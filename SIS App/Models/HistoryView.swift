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
    var font: Font = .body
    
    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .frame(width: 25, height: 25)
            
            Text(text)
                .font(font)
                .multilineTextAlignment(.leading)
        }
    }
}

struct HistoryRow: View {
    var session: CheckInSession
    
    var body: some View {
        VStack(alignment: .leading) {
            RowItem(
                iconName: "time",
                text: session.formattedTiming,
                font: .system(size: 20)
            )
            
            HStack {
                if let roomTarget = session.target as? Room {
                    RowItem(
                        iconName: "block",
                        text: RoomParentInfo.getParent(of: roomTarget)
                    )
                    RowItem(
                        iconName: "room",
                        text: session.target.name
                    )
                } else if let blockTarget = session.target as? Block {
                    RowItem(iconName: "block", text: blockTarget.name)
                }
            }
        }
    }
}
