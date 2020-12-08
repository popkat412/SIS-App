//
//  SessionInvalidError.swift
//  SIS App
//
//  Created by Wang Yunze on 30/11/20.
//

import Foundation

enum SessionInvalidError: String, Identifiable {
    case checkedOutBeforeCheckedIn = "You can't check out before you check in silly boi"
    case sessionsIntersecting = "You can't be in two places at once, stop trying to break the system"

    var id: String { rawValue }
}
