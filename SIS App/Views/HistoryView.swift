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
    @State private var currentlySelectedSession: CheckInSession? = nil

    @State private var alertItem: AlertItem?
    @State private var showingActivityIndicator: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
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
                if showingActivityIndicator {
                    MyActivityIndicator()
                        .frame(width: Constants.activityIndicatorSize, height: Constants.activityIndicatorSize)
                }
            }
            .listStyle(InsetListStyle()) // Must set this, if not adding the EditButton() ruins how the list looks
            .navigationBarTitle("History")
            .navigationBarItems(trailing: EditButton())
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
            .alert(item: $alertItem, content: alertItemBuilder)
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
