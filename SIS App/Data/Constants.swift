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
    static let urlScheme = "sg.tk.2020.risafeentry.url"
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

    // -------- [[ MAPVIEW STUFF ]] -------- //
    static let shouldDrawDebugGeofences = false
    static let mapViewAnnotationImageSize = 20

    // -------- [[ COLOR PALETTE ]] -------- //
    static let greenGradient = Gradient(colors: [
        Color(red: 35 / 225, green: 122 / 225, blue: 87 / 225),
        Color(red: 9 / 225, green: 48 / 225, blue: 40 / 225),
    ])
    static let blueGradient = Gradient(colors: [
        Color(red: 5 / 255, green: 117 / 255, blue: 230 / 255),
        Color(red: 2 / 255, green: 27 / 255, blue: 121 / 255),
    ])

    // ------ [[ FILENAMES ]] --------- //
    static let savedSessionsFilename = "savedSessions.json"
    static let currentSessionFilename = "currentSession.json"
    static let userLocationFilename = "userLocation.json"

    static let roomsFilename = "rooms.json"
    static let levelColorsFilename = "colors.json"
    static let categoryToDisplayNameFilename = "categories.json"
    static let blockOutlineFilename = "overlay_coords.json"
    static let checkInOutSoundFilename = "checkInOut"
    static let checkInOutSoundFileExtnesion = "mp3"

    static let roomIdToParentFilename = "roomIdToParent.json"

    static let overlayOutlineColorName = "Overlay Outline"

    // ------ [[ IDENTIFIERS ]] ------- //
    static let appGroupIdentifier = "group.sg.tk.2020.risafeentry.widget"

    static let remindUserFillInRoomsNotificationIdentifier = "remind-user-fill-in-rooms"
    static let remindUserCheckOutNotificationIdentifier = "remind-user-check-out"
    static let didEnterSchoolNotificationIdentifier = "did-enter-school"
    static let didExitSchoolNotificationIdentifier = "did-exit-school"

    // ------ [[ NOTIFICATION CENTER USERINFO ]] ----- //
    static let notificationCenterBlockUserInfo = "block"

    // ------ [[ DELAYS ]] ----- //
    /// Time in seconds inside a building before geofence is triggered
    static let geofenceDelayTime: TimeInterval = 2 * 60
    /// Time in seconds between when a user is able to upload data again
    static let sendConfirmationEmailDelayTime: TimeInterval = 24 * 60 * 60
    /// Time in seconds before automatically checking in / out to give user some time to do it manually (if they want)
    static let autoCheckInOutDelayTime: TimeInterval = 60

    // ------ [[ TIME INTERVALS TO KEEP ]] ---- //
    static let timeIntervalToUpload: TimeInterval = 14 * 24 * 60 * 60
    static let timeIntervalToKeepOnDevice: TimeInterval = 30 * 24 * 60 * 60

    // ------- [[ OTHERS ]] ------- //
    static let activityIndicatorSize: CGFloat = 60
    static let riEmailSuffix = "ri.edu.sg"

    // ------- [[ FIREBASE ]] ------ //
    static let sendConfirmationEmailCloudFunction = "sendConfirmationEmail"
    static let uploadedHistoryCollection = "history"
    static let historyCollectionForEachDocument = "history"
    static let sendWarningEmailCloudFucntion = "sendWarningEmail"

    // ------- [[ USER DEFAULTS ]] ------ //
    static let kLastSentConfirmationEmail = "kLastSentConfirmationEmail"
    static let kProcessedDocumentIds = "kProcessedDocumentIds"
    static let kDidAuthHistoryView = "kDidAuthHistoryView"

    // ------ [[ OTHER ]] ------ //
    static let remindUserFillInRoomsTime = DateComponents(hour: 18) // 6pm
    static let remindUserCheckOutTime = DateComponents(hour: 20) // 8pm
    static let riSafeEntryURL = URL(string: "https://www.safeentry-qr.gov.sg/tenant/PROD-T07GS3009E-390941-RAFFLESINSTITUTIONQR-SE")!
}
