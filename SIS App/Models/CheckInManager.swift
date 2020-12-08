//
//  CheckInManager.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation
import UserNotifications
import WidgetKit

class CheckInManager: ObservableObject {
    // MARK: Properties

    /// Used to check if the user is currently checked in or not
    /// This should check the persisted data (if any) from the `checkIn()` static method
    @Published private(set) var isCheckedIn = false

    /// This should control if the UI should show the check in screen or not, for better control over the UI
    /// This prevents the UI immediately changing to show something different when `checkIn()` or `checkOut()` is called
    @Published var showCheckedInScreen = false

    /// The current check in session. This is nil when the user isn't checked in
    @Published private(set) var currentSession: CheckInSession?

    /// The list of all check in sessions in the user's history
    @Published var checkInSessions: [CheckInSession] {
        didSet {
            FileUtility.saveDataToJsonFile(filename: Constants.savedSessionsFilename, data: checkInSessions)
            updateReminderNotification()

            objectWillChange.send()
        }
    }

    var mostRecentSession: CheckInSession? { checkInSessions.last }

    // MARK: Init

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

    // MARK: API

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

        // ------- [[ REMIND NOTIFICATION ]] ------ //
        UserNotificationHelper.hasScheduledNotification(withIdentifier: Constants.remindUserCheckOutNotificationIdentifier) { result in
            guard result == false else { return }

            UserNotificationHelper.sendNotification(
                title: "Remember to check out!",
                subtitle: "You aren't in school until that late right?",
                withIdentifier: Constants.remindUserCheckOutNotificationIdentifier,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: Constants.remindUserCheckOutTime,
                    repeats: false
                )
//                trigger: UNTimeIntervalNotificationTrigger(
//                    timeInterval: 10,
//                    repeats: false
//                )
            )
        }

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
        currentSession!.checkedOut = Date()

        // -------- [[ ADD TO SAVED SESSIONS ]] ------- //
        checkInSessions.append(currentSession!)

        // ------- [[ CLEANUP ]] -------- //
        currentSession = nil
        FileUtility.deleteFile(filename: Constants.currentSessionFilename)

        // ------- [[ REMINDER NOTIFICATION ------- //
        UserNotificationHelper.hasScheduledNotification(withIdentifier: Constants.remindUserCheckOutNotificationIdentifier) { result in
            guard result else { return }

            UserNotificationHelper.cancelScheduledNotification(withIdentifier: Constants.remindUserCheckOutNotificationIdentifier)
        }

        // ------- [[ UPDATE WIDGET ]] -------- //
        WidgetCenter.shared.reloadAllTimelines()
    }

    // TODO: Use an enum return instead of the possible invalid reasons
    /// This should use the UUID to figure out which session to change,
    /// then update that session based on the properties of the passed session.
    /// This will do nothing if the new session dates are not valid.
    /// If the new session dates are not valid, this will return the error, else nil
    @discardableResult
    func updateCheckInSession(id: UUID, newSession: CheckInSession) -> SessionInvalidError? {
        // Check if new session checks in before he checks out
        if newSession.checkedOut! < newSession.checkedIn { return .checkedOutBeforeCheckedIn }

        let idx = checkInSessions.firstIndex { $0.id == id }
        var newArr = checkInSessions
        if let idx = idx {
            newArr[idx] = newSession
        }

        let intersectionCheckResult = IntersectionChecker.checkIntersection(sessions: newArr)
        if intersectionCheckResult.isEmpty {
            print("🤔 yay no intersection")
            checkInSessions = newArr
            return nil
        } else {
            print("🤔 :( there was an intersection: \(intersectionCheckResult)")
            return .sessionsIntersecting
        }
    }

    /// This deletes a session
    /// This should use the UUID to figure out which session to delete
    func deleteCheckInSession(id: UUID) {
        checkInSessions.removeAll { $0.id == id }
    }

    /// This should get the user's history from CoreData
    /// The `CheckInSession`s should be sorted by date
    func getCheckInSessions(usingPlaceholderData: Bool = false) -> [Day] {
        if !usingPlaceholderData {
            return Dictionary(grouping: checkInSessions) { session -> Date in
                Calendar.current.startOfDay(for: session.checkedIn)
            }
            .map { key, value in
                Day(date: key, sessions: value)
            }
            .sorted { day1, day2 in
                day1.sessions.first!.checkedIn > day2.sessions.first!.checkedIn
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
            .sorted { day1, day2 in
                day1.sessions.first!.checkedIn > day2.sessions.first!.checkedIn
            }
        }
    }

    /// This is the method that will be called when user enters a block
    /// This is supposed to automatically check the user into a block for them to edit later
    @objc func didEnterBlock(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.autoCheckInOutDelayTime) { [self] in
            if isCheckedIn { return }
            let block = notification.userInfo?[Constants.notificationCenterBlockUserInfo] as! Block
            print("automatically checking in to \(block.name)")
            checkIn(to: block)
        }
    }

    /// This is the method that will be called when user exits a block
    /// This is supposed to automatically check the user out of a block for them to edit later
    @objc func didExitBlock(_: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.autoCheckInOutDelayTime) { [self] in
            if !isCheckedIn { return }
            print("automatically checking out")
            checkOut()
        }
    }

    // MARK: Private methods

    private func updateReminderNotification() {
        let hasSpecificRooms = checkInSessions
            .filter { Calendar.current.isDateInToday($0.checkedIn) }
            .reduce(false) { $1.target is Room }
        print("hasSpecificRooms: \(hasSpecificRooms)")

        UserNotificationHelper.hasScheduledNotification(withIdentifier: Constants.remindUserFillInRoomsNotificationIdentifier) { result in

            print("has scheduled \(Constants.remindUserFillInRoomsNotificationIdentifier): \(result)")

            if result, hasSpecificRooms {
                print("cancelling \(Constants.remindUserFillInRoomsNotificationIdentifier)")
                UserNotificationHelper.cancelScheduledNotification(withIdentifier: Constants.remindUserFillInRoomsNotificationIdentifier)

            } else if !hasSpecificRooms, !result {
                print("scheduling \(Constants.remindUserFillInRoomsNotificationIdentifier)")
                UserNotificationHelper.sendNotification(
                    title: "Please fill in your check in history",
                    subtitle: "Filling in specific rooms helps aid contact tracing",
                    withIdentifier: Constants.remindUserFillInRoomsNotificationIdentifier,
                    trigger: UNCalendarNotificationTrigger(dateMatching: Constants.remindUserFillInRoomsTime, repeats: false)
                )
            }
        }
    }
}
