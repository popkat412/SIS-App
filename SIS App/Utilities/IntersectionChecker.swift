//
//  IntersectionChecker.swift
//  SIS App
//
//  Created by Wang Yunze on 29/11/20.
//

import Foundation
import UIKit

struct IntersectionChecker {
    /// Checkes for intersections within a single array of CheckInSessions.
    /// This is to prevent user from editing history such that they check into 2 different places at the same time
    static func checkIntersection(sessions: [CheckInSession]) -> [DateInterval] {
        // 1. sort sessions by start date
        let sortedSessions = sessions.sorted { $0.checkedIn < $1.checkedIn }

        guard var previousEndTime = sessions.first?.checkedOut else { return [] }

        var results = [DateInterval]()

        for (idx, session) in sortedSessions.enumerated() {
            if idx == 0 { continue }

            // 2. For every session, check if the start date is more than previous end date
            // If its more, then ok, if it's less, there's an intersection
            if session.checkedIn < previousEndTime {
                // Force unwrapping here because unless my algo is wrong,
                // there should confirm be a intersection
                results.append(session.checkIntersection(with: sortedSessions[idx - 1])!)
            }

            guard let checkedOut = session.checkedOut else { return [] }
            previousEndTime = checkedOut
        }

        return results
    }
}

/// This should be the same intersection as the cloud function accepts
struct Intersection: Codable {
    var start: Date
    var end: Date
    var target: String

    init(start: Date, end: Date, target: String) {
        self.start = start
        self.end = end
        self.target = target
    }

    init(dateInterval: DateInterval, target: String) {
        start = dateInterval.start
        end = dateInterval.end
        self.target = target
    }
}
