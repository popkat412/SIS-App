//
//  AlertItem.swift
//  SIS App
//
//  Created by Wang Yunze on 3/12/20.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: String
    var message: String?
    var dismissButton: Alert.Button?
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?
}

func alertItemBuilder(_ alertItem: AlertItem) -> Alert {
    guard let primaryButton = alertItem.primaryButton, let secondaryButton = alertItem.secondaryButton else {
        return Alert(
            title: Text(alertItem.title),
            message: alertItem.message == nil ? nil : Text(alertItem.message!),
            dismissButton: alertItem.dismissButton
        )
    }
    return Alert(
        title: Text(alertItem.title),
        message: alertItem.message == nil ? nil : Text(alertItem.message!),
        primaryButton: primaryButton,
        secondaryButton: secondaryButton
    )
}
