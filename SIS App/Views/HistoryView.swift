//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import LocalAuthentication
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    @State private var showingEditRoomScreen = false
    @State private var currentlySelectedSession: CheckInSession? = nil

    var body: some View {
        VStack {
            if UserDefaults(suiteName:Constants.appGroupIdentifier)?.bool(forKey: "didAuthHistoryView") ?? false {
                NavigationView {
                    List {
                        ForEach(checkInManager.getCheckInSessions()) { day in
                            Section(header: Text("\(day.formattedDate)")) {
                                ForEach(day.sessions) { session in
                                    HistoryRow(
                                        session: session,
                                        editable: true,
                                        currentlySelectedSession: $currentlySelectedSession,
                                        onTargetPressed: {
                                            showingEditRoomScreen = true
                                        },
                                        onCheckInDateUpdate: { newCheckInDate in
                                            guard let currentlySelectedSession = currentlySelectedSession else { return }

                                            print("🗂 new check in date: \(newCheckInDate)")
                                            checkInManager.updateCheckInSession(
                                                id: currentlySelectedSession.id,
                                                newSession: currentlySelectedSession.newSessionWith(checkedIn: newCheckInDate)
                                            )
                                        },
                                        onCheckOutDateUpdate: { newCheckOutDate in
                                            guard let currentlySelectedSession = currentlySelectedSession else { return }

                                            print("🗂 new check out date: \(newCheckOutDate)")
                                            checkInManager.updateCheckInSession(
                                                id: currentlySelectedSession.id,
                                                newSession: currentlySelectedSession.newSessionWith(checkedOut: newCheckOutDate)
                                            )
                                        }
                                    )
                                    .popover(isPresented: $showingEditRoomScreen) {
                                        ChooseRoomView(onRoomSelection: { room in
                                            showingEditRoomScreen = false

                                            guard let currentlySelectedSession = currentlySelectedSession else { return }
                                            print("🗂 saving session: \(session)")
                                            checkInManager.updateCheckInSession(
                                                id: currentlySelectedSession.id,
                                                newSession: currentlySelectedSession.newSessionWith(target: room)
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
                    .listStyle(InsetListStyle()) // Must set this, if not addign the EditButton() ruins how the list looks
                    .navigationBarTitle("History")
                    .navigationBarItems(trailing: EditButton())
                }
            } else {
                Text("Not authenticated")
            }
        }
        .onAppear {
            if !(UserDefaults(suiteName: Constants.appGroupIdentifier)?.bool(forKey: "didAuthHistoryView") ?? false) {
                authenticate()
                print("aaa")
            }
        }
    }
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "To access your check in history"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        UserDefaults(suiteName: Constants.appGroupIdentifier)?.set(true, forKey: "didAuthHistoryView")
                    } else {
                        print("bbb")
                        UserDefaults(suiteName: Constants.appGroupIdentifier)?.set(false, forKey: "didAuthHistoryView")
                    }
                }
            }
        } else {
            print("ccc")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}
