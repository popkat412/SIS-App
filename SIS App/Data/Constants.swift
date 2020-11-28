//
//  Constants.swift
//  SIS App
//
//  Created by Wang Yunze on 24/11/20.
//

import CoreLocation
import Foundation
import SwiftUI

struct Constants {
    // -------- [[ DEEPLINK URLS ]] --------- //
    static let urlScheme = "com.example.ri-safe-entry"
    static let urlHost = "widgetlink"
    static let baseURLString = "\(urlScheme)://\(urlHost)"
    static let baseURL = URL(string: Constants.baseURLString)!

    static let blockURLParameterName = "block"
    static let checkoutURLName = "checkout"
    static let historyURLName = "history"

    // -------- [[ SCHOOL LOCATION INFO ]] --------- //
    static let schoolLocation = CLLocation(latitude: 1.347014, longitude: 103.845148)
    static let schoolRadius = 222.94
    static let schoolRegionId = "Y14"

    // -------- [[ COLOR PALETTE ]] -------- //
    static let checkedInGradient = Gradient(colors: [
        Color(red: 35 / 225, green: 122 / 225, blue: 87 / 225),
        Color(red: 9 / 225, green: 48 / 225, blue: 40 / 225),
    ])
    static let checkedOutGradient = Gradient(colors: [
        Color(red: 67 / 255, green: 198 / 255, blue: 172 / 255),
        Color(red: 25 / 255, green: 22 / 255, blue: 84 / 255),
    ])

    // ------ [[ FILENAMES ]] --------- //
    static let savedSessionsFilename = "savedSessions.json"
    static let currentSessionFilename = "currentSession.json"
    static let userLocationFilename = "userLocation.json"

    static let roomsFilename = "rooms.json"
    static let levelColorsFilename = "colors.json"
    static let categoryToDisplayNameFilename = "categories.json"

    static let roomIdToParentFilename = "roomIdToParent.json"

    // ------ [[ IDENTIFIERS ]] ------- //
    static let appGroupIdentifier = "group.com.example.ri-safe-entry"
    static let remindUserFillInRoomsNotificationIdentifier = "remind-user-fill-in-rooms"

    // ------ [[ NOTIFICATION CENTER USERINFO ]] ----- //
    static let notificationCenterBlockUserInfo = "block"

    // ------ [[ OTHER ]] ------ //
    static let remindUserFillInRoomsTime = DateComponents(hour: 18)
}
