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

    @State private var alertItem: AlertItem?
    @State private var showingActivityIndicator: Bool = false

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
                                        onCheckInDateUpdate: { newCheckInDate, _ in
                                            guard let currentlySelectedSession = currentlySelectedSession else { return nil }

                                            print("🗂 new check in date: \(newCheckInDate)")
                                            return checkInManager.updateCheckInSession(
                                                id: currentlySelectedSession.id,
                                                newSession: currentlySelectedSession.newSessionWith(checkedIn: newCheckInDate)
                                            )
                                        },
                                        onCheckOutDateUpdate: { newCheckOutDate, _ in
                                            guard let currentlySelectedSession = currentlySelectedSession else { return nil }

                                            print("🗂 new check out date: \(newCheckOutDate)")
                                            return checkInManager.updateCheckInSession(
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
                    .alert(item: $alertItem, content: alertItemBuilder)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button(action: {}) {
                                HStack {
                                    Text("Add")
                                    Image(systemName: "plus")
                                }
                            }
                            Button(action: {
                                let lastSentConfirmationEmail = UserDefaults(suiteName: Constants.appGroupIdentifier)?.double(forKey: Constants.kLastSentConfirmationEmail)

                                var difference: Double?
                                if let lastSentConfirmationEmail = lastSentConfirmationEmail {
                                    difference = Date().timeIntervalSince1970 - lastSentConfirmationEmail
                                }
                                if lastSentConfirmationEmail == nil || (difference != nil && difference! >= Constants.sendConfirmationEmailDelayTime) {
                                    alertItem = AlertItem(
                                        title: "Holup!",
                                        message: "Are you sure you want to upload data? An email will be sent to the school to confirm that you are not trolling.",
                                        primaryButton: .cancel(),
                                        secondaryButton: .destructive(Text("Yes"), action: sendConfirmationEmail)
                                    )
                                } else {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "h:mm a, MMM d"
                                    let formatted = dateFormatter.string(from: Date(timeIntervalSince1970: lastSentConfirmationEmail!).addingTimeInterval(Constants.sendConfirmationEmailDelayTime))
                                    alertItem = AlertItem(
                                        title: "Woah chill bro",
                                        message: "You're uploading too fast. You can't upload until \(formatted)"
                                    )
                                }
                            }) {
                                HStack {
                                    Text("Upload")
                                    Image(systemName: "square.and.arrow.up.on.square")
                                }
                            }
                        }
                    }
                    if showingActivityIndicator {
                        MyActivityIndicator()
                            .frame(width: Constants.activityIndicatorSize, height: Constants.activityIndicatorSize)
                    }
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

    // MARK: Helper functions

    private func sendConfirmationEmail() {
        showingActivityIndicator = true
        EmailHelper.sendConfirmationEmail(data: checkInManager.checkInSessions.filter {
            let dateToKeep = Date() - Constants.timeIntervalToUpload
            return $0.checkedIn > dateToKeep || $0.checkedOut! > dateToKeep
        }) { error in
            if let error = error {
                alertItem = MyErrorInfo(error).toAlertItem {
                    showingActivityIndicator = false
                }
            } else {
                alertItem = AlertItem(
                    title: "Success!",
                    message: "Email has been sent successfully",
                    dismissButton: .default(Text("Yay")) {
                        showingActivityIndicator = false
                    }
                )
                UserDefaults(suiteName: Constants.appGroupIdentifier)?.setValue(Date().timeIntervalSince1970, forKey: Constants.kLastSentConfirmationEmail)
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
