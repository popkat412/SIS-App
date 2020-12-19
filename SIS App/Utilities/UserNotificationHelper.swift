//
//  UserNotificationHelper.swift
//  SIS App
//
//  Created by Wang Yunze on 14/11/20.
//

import Foundation
import UserNotifications

struct UserNotificationHelper {
    static let notificationCenter = UNUserNotificationCenter.current()

    /// Send / Schedule a notification.
    /// If `trigger != nil`, then a notification is scheduled,
    /// else it is sent immediately
    static func sendNotification(title: String, subtitle: String, identifier: String? = nil, trigger: UNNotificationTrigger? = nil) {
        print("📣 sending notification: \(title)")

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: identifier ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    /// Check if a notification with a idnetifier has already been scheduled
    static func hasScheduledNotification(withIdentifier identifier: String, completion: @escaping (Bool) -> Void) {
        notificationCenter.getPendingNotificationRequests { notificationRequests in
            var hasNotification = false
            for request in notificationRequests {
                if request.identifier == identifier {
                    hasNotification = true
                }
            }
            completion(hasNotification)
        }
    }

    /// Cancel an already schedules notification with a identifier
    static func cancelScheduledNotification(withIdentifier identifier: String) {
        notificationCenter.getPendingNotificationRequests { _ in
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }

    /// Request for permission to send notifications
    static func requestAuth() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("request user notification auth success")
            } else if let error = error {
                print("error while requesting user notification auth: \(error.localizedDescription)")
            } else {
                print("Unknown error occurred when requesting user notifications")
            }
        }
    }
}
