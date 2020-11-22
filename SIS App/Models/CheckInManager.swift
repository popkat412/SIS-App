//
//  CheckInManager.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation
import WidgetKit

class CheckInManager: ObservableObject {
    /// Used to check if the user is currently checked in or not
    /// This should check the persisted data (if any) from the `checkIn()` static method
    @Published private(set) var isCheckedIn = false

    /// This should control if the UI should show the check in screen or not, for better control over the UI
    /// This prevents the UI immediately changing to show something different when `checkIn()` or `checkOut()` is called
    @Published var showCheckedInScreen = false

    /// The current check in session. This is nil when the user isn't checked in
    @Published private(set) var currentSession: CheckInSession?

    @Published var checkInSessions: [CheckInSession] {
        didSet {
            FileUtility.saveDataToJsonFile(filename: Constants.savedSessionsFilename, data: checkInSessions)
            objectWillChange.send()
        }
    }

    init() {
        checkInSessions = FileUtility.getDataFromJsonFile(
            filename: Constants.savedSessionsFilename,
            dataType: [CheckInSession].self
        )
            ?? []

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBlock), name: .didEnterBlock, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didExitBlock), name: .didExitBlock, object: nil)

        // ------- [[ RESTORE CHECK IN STATE ]] ----------- //
        let previousCheckIn = FileUtility.getDataFromJsonFile(
            filename: Constants.currentSessionFilename,
            dataType: CheckInSession.self
        )
        if previousCheckIn != nil {
            currentSession = previousCheckIn
            isCheckedIn = true
            showCheckedInScreen = true
        }
    }

    /// Used to check the user into a room.
    /// Note that this should persist if the user quits the app while checked in
    /// This should never be called when `isCheckedIn` is true
    func checkIn(to room: CheckInTarget, shouldUpdateUI: Bool = true) {
        if isCheckedIn == true { return }

        // ------- [[ UPDATE STATE ]] -------- //
        isCheckedIn = true
        if shouldUpdateUI { showCheckedInScreen = true }
        currentSession = CheckInSession(checkedIn: Date(), checkedOut: nil, target: room)

        // ------- [[ SAVE CURRENT SESSION TO FILE ]] ------ //
        FileUtility.saveDataToJsonFile(filename: Constants.currentSessionFilename, data: currentSession)

        // ------- [[ UPDATE WIDGET ]] -------- //
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Used to check the user out from the room they are currently checked into
    /// This should use the persisted data (if any) from the `checkIn()` static method
    /// This should never be called when `isCheckedIn` is false
    func checkOut(shouldUpdateUI: Bool = true) {
        // ------- [[ SET STATE ]] -------- //
        isCheckedIn = false
        if shouldUpdateUI { showCheckedInScreen = false }
        currentSession?.checkedOut = Date()

        // -------- [[ ADD TO SAVED SESSIONS ]] ------- //
        checkInSessions.append(currentSession!)

        // ------- [[ CLEANUP ]] -------- //
        currentSession = nil
        FileUtility.deleteFile(filename: Constants.currentSessionFilename)

        // ------- [[ UPDATE WIDGET ]] -------- //
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// This should use the UUID to figure out which session to change,
    /// then update that session based on the properties of the passed session
    func updateCheckInSession(id: UUID, newSession: CheckInSession) {
        let idx = checkInSessions.firstIndex { $0.id == id }
        if let idx = idx {
            checkInSessions[idx] = newSession
        }
    }

    /// This deletes a session
    /// This should use the UUID to figure out which session to delete
    func deleteCheckInSession(id: UUID) {
        checkInSessions.removeAll { $0.id == id }
    }

    /// This should get the user's history from CoreData
    /// The `CheckInSession`s should be sorted by date
    func getCheckInSessions(placholderData: Bool = false) -> [Day] {
        if !placholderData {
            return Dictionary(grouping: checkInSessions) { session -> Date in
                Calendar.current.startOfDay(for: session.checkedIn)
            }
            .map { key, value in
                Day(date: key, sessions: value)
            }
        } else {
            return [
                Day(
                    date: Date(timeIntervalSince1970: 1_604_840_241),
                    sessions: [
                        CheckInSession(
                            checkedIn: Date(timeIntervalSince1970: 1_604_840_241),
                            checkedOut: Date(timeIntervalSince1970: 1_604_840_241 + 3600),
                            target: Room(name: "Class 1A", level: 1, id: "C1-17")
                        ),
                        CheckInSession(
                            checkedIn: Date(timeIntervalSince1970: 1_604_840_882),
                            checkedOut: Date(timeIntervalSince1970: 1_604_840_882 + 3600),
                            target: Room(name: "Computer Lab 3", level: 2, id: "J2-6")
                        ),
                        CheckInSession(
                            checkedIn: Date(timeIntervalSince1970: 1_604_841_082),
                            checkedOut: Date(timeIntervalSince1970: 1_604_841_082 + 3600),
                            target: Block("Raja Block")
                        ),
                    ]
                ),
                Day(
                    date: Date(timeIntervalSince1970: 1_604_922_272),
                    sessions: [
                        CheckInSession(
                            checkedIn: Date(timeIntervalSince1970: 1_604_922_272),
                            checkedOut: Date(timeIntervalSince1970: 1_604_922_272 + 3600),
                            target: Room(name: "Class 1A", level: 1, id: "C1-17")
                        ),
                        CheckInSession(
                            checkedIn: Date(timeIntervalSince1970: 1_604_925_272),
                            checkedOut: Date(timeIntervalSince1970: 1_604_925_272 + 3600),
                            target: Room(name: "Computer Lab 3", level: 2, id: "J2-6")
                        ),
                    ]
                ),
            ]
        }
    }

    /// This is the method that will be called when user enters a block
    /// This is supposed to automatically check the user into a block for them to edit later
    @objc func didEnterBlock(_ notification: Notification) {
        if isCheckedIn { return }
        let block = notification.userInfo?[Constants.notificationCenterBlockUserInfo] as! Block
        print("automatically checking in to \(block.name)")
        checkIn(to: block)
    }

    /// This is the method that will be called when user exits a block
    /// This is supposed to automatically check the user out of a block for them to edit later
    @objc func didExitBlock(_: Notification) {
        if !isCheckedIn { return }
        print("automatically checking out")
        checkOut()
    }
}
