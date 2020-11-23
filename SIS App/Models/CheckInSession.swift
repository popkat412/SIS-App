//
//  CheckInSession.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import Foundation

struct Day: Identifiable {
    var id = UUID()
    var date: Date
    var sessions: [CheckInSession]
    
    var formattedDate: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM y"
            
            return formatter.string(from: date)
        }
    }
}

struct CheckInSession: Identifiable {
    var checkedIn: Date
    var checkedOut: Date?
    var target: CheckInTarget
    var id = UUID()
    
    var formattedTiming: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            
            if checkedOut != nil {
                 return "\(formatter.string(from: checkedIn)) - \(formatter.string(from: checkedOut!))"
            } else {
                return "\(formatter.string(from: checkedIn)) - ???"
            }
        }
    }
    
    func newSessionWith(checkedIn: Date? = nil, checkedOut: Date? = nil, target: CheckInTarget? = nil, id: UUID? = nil) -> CheckInSession {
        return CheckInSession(
            checkedIn: checkedIn ?? self.checkedIn,
            checkedOut: checkedOut ?? self.checkedOut,
            target: target ?? self.target,
            id: id ?? self.id
        )
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
        
        self.checkedIn = try container.decode(Date.self, forKey: .checkedIn)
        self.checkedOut = try container.decodeIfPresent(Date.self, forKey: .checkedOut)
        self.id = try container.decode(UUID.self, forKey: .id)
        if let roomTarget = try? container.decode(Room.self, forKey: .target) {
            self.target = roomTarget
        } else if let blockTarget = try? container.decode(Block.self, forKey: .target) {
            self.target = blockTarget
        } else {
            self.target = Room(name: "Unknown Target :(", level: 0, id: "00-00")
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
        if let roomTarget = target as? Room {
            try container.encode(roomTarget, forKey: .target)
        } else if let blockTarget = target as? Block {
            try container.encode(blockTarget, forKey: .target)
        }
    }
    
}
