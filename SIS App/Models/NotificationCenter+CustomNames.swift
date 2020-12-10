//
//  NotificationCenter+CustomNames.swift
//  SIS App
//
//  Created by Wang Yunze on 13/11/20.
//

import Foundation

extension Notification.Name {
    static let didEnterBlock = Notification.Name("didEnterBlock")
    static let didExitBlock = Notification.Name("didExitBlock")
    static let didEnterSchool = Notification.Name("didEnterSchool")
    static let didExitSchool = Notification.Name("didExitSchool")
    static let didSwitchToHistoryView = Notification.Name("didSwitchToHistoryView")
}
