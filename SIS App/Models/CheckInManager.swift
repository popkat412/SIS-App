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
    
//    static var isCheckedIn: Bool {
//        get {
//            // TODO: Implement this
//            return _isCheckedIn
//        }
//    };
    
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
}
