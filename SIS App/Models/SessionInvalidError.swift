//
//  SessionInvalidError.swift
//  SIS App
//
//  Created by Wang Yunze on 30/11/20.
//

import Foundation

/// Possible reasons as to why a change to a session isn't valid
enum SessionInvalidError: String, Identifiable {
    case checkedOutBeforeCheckedIn = "You can't check out before you check in"
    case sessionsIntersecting = "You can't be in two places at once"

    var id: String { rawValue }
}
