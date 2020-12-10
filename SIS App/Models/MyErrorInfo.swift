//
//  MyErrorInfo.swift
//  SIS App
//
//  Created by Wang Yunze on 2/12/20.
//

import Foundation
import SwiftUI

struct MyErrorInfo: Identifiable {
    var message: String
    var error: Error?
    var id = UUID()

    init(_ error: Error) {
        self.error = error
        message = error.localizedDescription
    }

    init(_ error: String) {
        self.error = nil
        message = error
    }

    func toAlertItem(onDismiss: @escaping () -> Void) -> AlertItem {
        print("🔥 toAlertItem: \(String(describing: error))")
        return AlertItem(
            title: "Whoops!",
            message: message,
            dismissButton: .default(Text("Got it!"), action: onDismiss)
        )
    }
}
