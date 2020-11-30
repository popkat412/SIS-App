//
//  UserNotificationHelper.swift
//  SIS App
//
//  Created by Wang Yunze on 14/11/20.
//

import Foundation
import UserNotifications

struct UserNotificationHelper {
    static func sendNotification(title: String, subtitle: String, identifier: String? = nil, trigger: UNNotificationTrigger? = nil) {
        print("sending notification: \(title)")

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: identifier ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func requestAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
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
