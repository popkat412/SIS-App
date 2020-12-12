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

    @AppStorage(Constants.kDidAuthHistoryView, store: UserDefaults(suiteName: Constants.appGroupIdentifier)) var isAuthenticated: Bool = false

    @State private var showingEditRoomScreen = false
    @State private var currentlySelectedSession: CheckInSession? = nil

    @State private var alertItem: AlertItem?
    @State private var showingActivityIndicator: Bool = false

    var body: some View {
        VStack {
            if isAuthenticated {
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
                                            onCheckInDateUpdate: onCheckInDateUpdate,
                                            onCheckOutDateUpdate: { newCheckOutDate, _ in
                                                guard let currentlySelectedSession = currentlySelectedSession else { return nil }

                                                print("🗂 new check out date: \(newCheckOutDate)")
                                                return checkInManager.updateCheckInSession(
                                                    id: currentlySelectedSession.id,
                                                    newSession: currentlySelectedSession.newSessionWith(checkedOut: newCheckOutDate)
                                                )
                                            }
                                        )
                                        .sheet(isPresented: $showingEditRoomScreen) {
                                            ChooseRoomView(onRoomSelection: { target in
                                                showingEditRoomScreen = false
                                                guard let currentlySelectedSession = currentlySelectedSession else { return }
                                                print("🗂 saving session: \(session)")
                                                checkInManager.updateCheckInSession(
                                                    id: currentlySelectedSession.id,
                                                    newSession: currentlySelectedSession.newSessionWith(target: target)
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
//                            Button(action: {}) {
//                                HStack {
//                                    Text("Add")
//                                    Image(systemName: "plus")
//                                }
//                            }
                            Button(action: {
                                let lastSentConfirmationEmail = UserDefaults(suiteName: Constants.appGroupIdentifier)?.double(forKey: Constants.kLastSentConfirmationEmail)

                                var difference: Double?
                                if let lastSentConfirmationEmail = lastSentConfirmationEmail {
                                    difference = Date().timeIntervalSince1970 - lastSentConfirmationEmail
                                }
                                if lastSentConfirmationEmail == nil || (difference != nil && difference! >= Constants.sendConfirmationEmailDelayTime) {
                                    alertItem = AlertItem(
                                        title: "Are you sure you want to upload data?",
                                        message: "An email will be sent to the school to confirm that you are not trolling.",
                                        primaryButton: .cancel(),
                                        secondaryButton: .destructive(Text("Yes"), action: sendConfirmationEmail)
                                    )
                                } else {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "h:mm a, MMM d"
                                    let formatted = dateFormatter.string(from: Date(timeIntervalSince1970: lastSentConfirmationEmail!).addingTimeInterval(Constants.sendConfirmationEmailDelayTime))
                                    alertItem = AlertItem(
                                        title: "You're uploading too fast. You can't upload until \(formatted)"
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
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                Text("Not authenticated")
                Button("Try again", action: authenticate)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didSwitchToHistoryView)) { _ in
            print("🧑‍💻 switched to history view")
            if !isAuthenticated {
                authenticate()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            isAuthenticated = false
        }
    }

    // MARK: Helper functions

    private func onCheckInDateUpdate(_ newCheckInDate: Date, _: Date) -> SessionInvalidError? {
        guard let currentlySelectedSession = currentlySelectedSession else { return nil }

        print("🗂 new check in date: \(newCheckInDate)")
        return checkInManager.updateCheckInSession(
            id: currentlySelectedSession.id,
            newSession: currentlySelectedSession.newSessionWith(checkedIn: newCheckInDate)
        )
    }

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
                    dismissButton: .default(Text("Ok")) {
                        showingActivityIndicator = false
                    }
                )
                UserDefaults(suiteName: Constants.appGroupIdentifier)?.setValue(Date().timeIntervalSince1970, forKey: Constants.kLastSentConfirmationEmail)
            }
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "To unlock your location history") { success, error in
                print("🧑‍💻 LA result: \(success)")
                DispatchQueue.main.async {
                    isAuthenticated = success
                }

                if let error = error { print("🧑‍💻 LA error: \(error)") }
            }
        } else {
            print("🧑‍💻 device doesn't support LA: \(String(describing: error))")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(CheckInManager())
    }
}
