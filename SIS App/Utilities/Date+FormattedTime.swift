//
//  Date+FormattedTime.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import Foundation

extension Date {
    /// The date, formatted as a time
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: self)
    }
}
