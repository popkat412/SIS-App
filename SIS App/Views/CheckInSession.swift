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
}
