//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import LocalAuthentication
import NotificationCenter
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    @State private var showingEditRoomScreen = false
    @State private var isAuthenticated = false
    @State private var currentlySelectedSession: CheckInSession? = nil

    var body: some View {
        VStack {
            if isAuthenticated {
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
                Button("Try again", action: {
                    authenticate()
                })
            }
        }
        .onAppear {
            isAuthenticated = UserDefaults(suiteName: Constants.appGroupIdentifier)?.bool(forKey: Constants.kDidAuthHistoryView) ?? false
            print("🧑‍💻 history view appeared, isAuthenticated: \(isAuthenticated)")
            if !isAuthenticated {
                print("🧑‍💻 not authenticed, authenticating")
                authenticate()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("🧑‍💻 moving to background")
            isAuthenticated = false
            UserDefaults(suiteName: Constants.appGroupIdentifier)?.setValue(false, forKey: Constants.kDidAuthHistoryView)
        }
    }

    private func authenticate() {
        print("🧑‍💻 authenticate() called")
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "To access your check in history"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        print("🧑‍💻 auth successful successful")
                        UserDefaults(suiteName: Constants.appGroupIdentifier)?.set(true, forKey: Constants.kDidAuthHistoryView)
                        isAuthenticated = true
                    } else {
                        print("🧑‍💻 auth not successful")
                        UserDefaults(suiteName: Constants.appGroupIdentifier)?.set(false, forKey: Constants.kDidAuthHistoryView)
                        isAuthenticated = false
                    }
                }
            }
        } else {
            print("🧑‍💻 error device cannot auth")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}
