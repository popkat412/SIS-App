//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    @State private var showingEditRoomScreen = false

    @State private var showingErrorAlert = false
    @State private var currentError: SessionInvalidError?

    var body: some View {
        NavigationView {
            List {
                ForEach(checkInManager.getCheckInSessions()) { day in
                    Section(header: Text("\(day.formattedDate)")) {
                        ForEach(day.sessions) { session in
                            HistoryRow(
                                session: session,
                                editable: true,
                                onTargetPressed: {
                                    showingEditRoomScreen = true
                                },
                                onCheckInDateUpdate: { newCheckInDate, _ in
                                    print("new check in date: \(newCheckInDate)")
                                    return checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(checkedIn: newCheckInDate)
                                    )
                                },
                                onCheckOutDateUpdate: { newCheckOutDate, _ in
                                    print("new check out date: \(newCheckOutDate)")
                                    return checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(checkedOut: newCheckOutDate)
                                    )
                                }
                            )
                            .popover(isPresented: $showingEditRoomScreen) {
                                ChooseRoomView(onRoomSelection: { room in
                                    showingEditRoomScreen = false

                                    checkInManager.updateCheckInSession(
                                        id: session.id,
                                        newSession: session.newSessionWith(target: room)
                                    )
                                }, onBackButtonPressed: {
                                    showingEditRoomScreen = false
                                })
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                checkInManager.deleteCheckInSession(id: day.sessions[index].id)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetListStyle()) // Must set this, if not adding the EditButton() ruins how the list looks
            .navigationBarTitle("History")
            .navigationBarItems(trailing: EditButton())
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}
