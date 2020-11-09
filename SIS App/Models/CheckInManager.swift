//
//  CheckInManager.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation

//class CheckInInfo: ObservableObject {
//    @Published var isCheckedIn = CheckInManager.isCheckedIn
//}

class CheckInManager: ObservableObject {
    /// Used to check if the user is currently checked in or not
    /// This should check the persisted data (if any) from the `checkIn()` static method
    @Published private(set) var isCheckedIn = false
    
    /// Used to check the user into a room.
    /// Note that this should persist if the user quits the app while checked in
    /// This should never be called when `isCheckedIn` is true
    func checkIn(to: Room) {
        // TODO: Implement this
        isCheckedIn = true
    }
    
    /// Used to check the user out from the room they are currently checked into
    /// This should use the persisted data (if any) from the `checkIn()` static method
    /// This should never be called when `isCheckedIn` is false
    func checkOut() {
        // TODO: Implement this
        isCheckedIn = false
    }
    
    /// This should get the user's history from CoreData
    func getCheckInSessions() -> [Day] {
        // TODO: Implemenet this
        // For now, return dummy data
        return [
            Day(
                date: Date(timeIntervalSince1970: 1604840241),
                sessions: [
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604840241),
                        checkedOut: Date(timeIntervalSince1970: 1604840241+3600),
                        room: Room(name: "Class 1A", level: 1, id: "C1-17")
                    ),
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604840882),
                        checkedOut: Date(timeIntervalSince1970: 1604840882+3600),
                        room: Room(name: "Computer Lab 3", level: 2, id: "J2-6")
                    )
                ]
            ),
            Day(
                date: Date(timeIntervalSince1970: 1604922272),
                sessions: [
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604922272),
                        checkedOut: Date(timeIntervalSince1970: 1604922272+3600),
                        room: Room(name: "Class 1A", level: 1, id: "C1-17")
                    ),
                    CheckInSession(
                        checkedIn: Date(timeIntervalSince1970: 1604925272),
                        checkedOut: Date(timeIntervalSince1970: 1604925272+3600),
                        room: Room(name: "Computer Lab 3", level: 2, id: "J2-6")
                    )
                ]
            )
        ]
    }
}
