//
//  HistoryView.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import LocalAuthentication
import SwiftUI

private struct StatsView: View {
    var num: String
    var text: String

    var body: some View {
        VStack {
            Text(num)
                .font(.system(size: 25))
            Text(text)
                .font(.system(size: 15, weight: .ultraLight, design: .default))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(width: 95, height: 100)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.3), radius: 10)
        .padding()
    }
}

struct HistoryView: View {
    @EnvironmentObject var checkInManager: CheckInManager

    @AppStorage(Constants.kDidAuthHistoryView, store: UserDefaults(suiteName: Constants.appGroupIdentifier)) var isAuthenticated: Bool = false

    @State private var showingEditRoomScreen = false
    @State private var currentlySelectedSession: CheckInSession? = nil

    @State private var alertItem: AlertItem?
    @State private var showingEnterPasswordAlert: Bool = false
    @State private var showingActivityIndicator: Bool = false

    var body: some View {
        GeometryReader { proxy in
            VStack {
                if isAuthenticated {
                    NavigationView {
                        VStack(spacing: 0) {
                            ScrollView(.horizontal) {
                                HStack {
                                    StatsView(num: "\(checkInManager.totalCheckIns)", text: "Total checkins")
                                    StatsView(num: "\(checkInManager.uniquePlaces)", text: "Unique places")
                                    StatsView(num: String(format: "%.1f", checkInManager.totalHours), text: "Total hours")
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                                .frame(height: 10)
                            MapView(
                                shouldRemainFixedAtSchool: true,
                                shouldShowTextLabels: true,
                                pinsToShow: { () -> [Location] in
                                    var s = Set<Location>()
                                    for session in checkInManager.checkInSessions {
                                        if let blockTarget = session.target as? Block {
                                            s.insert(blockTarget.location)
                                        } else if let roomTarget = session.target as? Room {
                                            s.insert(DataProvider.getBlock(id: RoomParentInfo.getParent(of: roomTarget))!.location)
                                        }
                                    }

                                    return Array(s)
                                }()
                            )
                            .frame(height: proxy.size.height / 3)
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
                                                    onCheckOutDateUpdate: onCheckOutDateUpdate
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
                            .alert(item: $alertItem, content: alertItemBuilder)
                            .layoutPriority(1)
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    Text("Not authenticated")
                    Button("Try again", action: authenticate)
                }
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

    private func onCheckOutDateUpdate(_ newCheckOutDate: Date, _: Date) -> SessionInvalidError? {
        guard let currentlySelectedSession = currentlySelectedSession else { return nil }

        print("🗂 new check out date: \(newCheckOutDate)")
        return checkInManager.updateCheckInSession(
            id: currentlySelectedSession.id,
            newSession: currentlySelectedSession.newSessionWith(checkedOut: newCheckOutDate)
        )
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
