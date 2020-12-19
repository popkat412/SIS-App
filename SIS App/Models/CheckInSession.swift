//
//  CheckInSession.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import FirebaseFirestore
import Foundation

/// This is a convenience struct containing all the check in sessions of a day
/// This is so things are easier in HistoryView's List
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

/// This is the main check in session struct
struct CheckInSession: Identifiable {
    var checkedIn: Date
    var checkedOut: Date?
    var target: CheckInTarget
    var id = UUID()

    /// Formats the timing nicely depending on whether it is checked out or not
    var formattedTiming: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        if checkedOut != nil {
            return "\(formatter.string(from: checkedIn)) - \(formatter.string(from: checkedOut!))"
        } else {
            return "\(formatter.string(from: checkedIn)) - ???"
        }
    }

    /// Convenience for getting the date interval of checkedIn and checkedOut times.
    /// If checkedOut is nil, this is nil too
    /// This is mainly used in the `checkIntersection` method
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

    /// Convenience for creating a new session with only a few different propreties
    /// The rest are copied over from this
    /// This is mostly for updating check in sessions
    func newSessionWith(checkedIn: Date? = nil, checkedOut: Date? = nil, target: CheckInTarget? = nil, id: UUID? = nil) -> CheckInSession {
        CheckInSession(
            checkedIn: checkedIn ?? self.checkedIn,
            checkedOut: checkedOut ?? self.checkedOut,
            target: target ?? self.target,
            id: id ?? self.id
        )
    }

    /// Convenience for getting getting checkedIn and checkedOut intersections
    /// between two `CheckInSessions`.
    /// If either of the checkedOut is nil, this returns nil too
    func checkIntersection(with other: CheckInSession) -> DateInterval? {
        guard let a = dateInterval, let b = other.dateInterval else { return nil }
        return a.intersection(with: b)
    }
}

/// Codable extension for decoding and encoding to json.
/// When encoding, this encodes the `CheckInTarget`s using their id.
/// When decoding, it takes the id and converts it back to a `CheckInTarget`,
/// returning `UnknownCheckInTarget()` if the conversion fails
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

extension CheckInSession {
    /// This is to quickly convert this to a firebase dictionary for use in Firestore
    /// The shape of the returned dictionary should be the same as the one in Firestore (see readme)
    func toFirebaseDictionary() -> [String: Any] {
        var temp = [String: Any]()

        temp["checkedIn"] = Timestamp(date: checkedIn)

        if let checkedOut = self.checkedOut { temp["checkedOut"] = Timestamp(date: checkedOut) }
        else { temp["checkedOut"] = nil }

        temp["target"] = target.id

        temp["id"] = id.uuidString

        return temp
    }
}
