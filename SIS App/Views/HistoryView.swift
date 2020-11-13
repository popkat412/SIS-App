//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    @State private var showingEditSession = false
    
    var body: some View {
        NavigationView{
            List {
                ForEach(checkInManager.getCheckInSessions()) { day in
                    Section(header: Text("\(day.formattedDate)")) {
                        ForEach(day.sessions) { session in
                            Button(action: {
                                showingEditSession = true
                            }) {
                                HistoryRow(session: session)
                            }
                            .sheet(isPresented: $showingEditSession) {
                                EditSessionView(
                                    session: session,
                                    showingEditSession: $showingEditSession
                                )
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("History")
        }
      
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}


struct HistoryRowItem: View {
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
    var showTiming = true
    var showTarget = true
    
    var body: some View {
        VStack(alignment: .leading) {
            if showTiming {
                HistoryRowItem(
                    iconName: "time",
                    text: session.formattedTiming,
                    font: .system(size: 20)
                )
            }
            
            if showTarget {
                HStack {
                    if let roomTarget = session.target as? Room {
                        HistoryRowItem(
                            iconName: "block",
                            text: RoomParentInfo.getParent(of: roomTarget)
                        )
                        HistoryRowItem(
                            iconName: "room",
                            text: session.target.name
                        )
                    } else if let blockTarget = session.target as? Block {
                        HistoryRowItem(iconName: "block", text: blockTarget.name)
                    }
                }
            }
        }
    }
}
