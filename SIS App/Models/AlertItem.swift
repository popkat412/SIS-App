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
    var title: Text
    var message: Text?
    var dismissButton: Alert.Button?
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?

    init(id: UUID = UUID(), title: Text, message: Text? = nil, dismissButton: Alert.Button? = nil, primaryButton: Alert.Button? = nil, secondaryButton: Alert.Button? = nil) {
        self.id = id
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }

    init(id: UUID = UUID(), title: String, message: String? = nil, dismissButton: Alert.Button? = nil, primaryButton: Alert.Button? = nil, secondaryButton: Alert.Button? = nil) {
        self.id = id
        self.title = Text(title)
        self.message = message == nil ? nil : Text(message!)
        self.dismissButton = dismissButton
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

func alertItemBuilder(_ alertItem: AlertItem) -> Alert {
    guard let primaryButton = alertItem.primaryButton, let secondaryButton = alertItem.secondaryButton else {
        return Alert(
            title: alertItem.title,
            message: alertItem.message,
            dismissButton: alertItem.dismissButton
        )
    }
    return Alert(
        title: alertItem.title,
        message: alertItem.message,
        primaryButton: primaryButton,
        secondaryButton: secondaryButton
    )
}
