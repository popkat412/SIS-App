//
//  CheckInSession.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import FirebaseFirestore
import Foundation

struct Day: Identifiable {
    var id = UUID()
    var date: Date
    var sessions: [CheckInSession]

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM y"

        return formatter.string(from: date)
    }

    init(date: Date, sessions: [CheckInSession]) {
        id = UUID()
        self.date = date
        self.sessions = sessions.sorted { $0.checkedIn > $1.checkedIn }
    }
}

struct CheckInSession: Identifiable {
    var checkedIn: Date
    var checkedOut: Date?
    var target: CheckInTarget
    var id = UUID()

    var formattedTiming: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        if checkedOut != nil {
            return "\(formatter.string(from: checkedIn)) - \(formatter.string(from: checkedOut!))"
        } else {
            return "\(formatter.string(from: checkedIn)) - ???"
        }
    }

    var dateInterval: DateInterval? {
        guard let checkedOut = checkedOut else { return nil }
        return DateInterval(start: checkedIn, end: checkedOut)
    }

    init(checkedIn: Date, checkedOut: Date? = nil, target: CheckInTarget, id: UUID = UUID()) {
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
        self.target = target
        self.id = id
    }

    func newSessionWith(checkedIn: Date? = nil, checkedOut: Date? = nil, target: CheckInTarget? = nil, id: UUID? = nil) -> CheckInSession {
        CheckInSession(
            checkedIn: checkedIn ?? self.checkedIn,
            checkedOut: checkedOut ?? self.checkedOut,
            target: target ?? self.target,
            id: id ?? self.id
        )
    }

    func checkIntersection(with other: CheckInSession) -> DateInterval? {
        guard let a = dateInterval, let b = other.dateInterval else { return nil }
        return a.intersection(with: b)
    }
}

extension CheckInSession: Codable {
    enum CodingKeys: String, CodingKey {
        case checkedIn
        case checkedOut
        case target
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        checkedIn = try container.decode(Date.self, forKey: .checkedIn)
        checkedOut = try container.decodeIfPresent(Date.self, forKey: .checkedOut)
        id = try container.decode(UUID.self, forKey: .id)

        let targetId = try container.decode(String.self, forKey: .target)
        if let blockTarget = DataProvider.getBlock(id: targetId) {
            target = blockTarget
        } else if let roomTarget = DataProvider.getRoom(id: targetId) {
            target = roomTarget
        } else {
            target = UnknownCheckInTarget()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(checkedIn, forKey: .checkedIn)
        try container.encode(id, forKey: .id)

        if checkedOut != nil {
            try container.encode(checkedOut, forKey: .checkedOut)
        } else {
            try container.encodeNil(forKey: .checkedOut)
        }

        try container.encode(target.id, forKey: .target)
    }
}
