//
//  UserNotificationHelper.swift
//  SIS App
//
//  Created by Wang Yunze on 14/11/20.
//

import Foundation
import UserNotifications

struct UserNotificationHelper {
    static func sendNotification(title: String, subtitle: String) {
        print("sending notification: \(title)")

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

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
