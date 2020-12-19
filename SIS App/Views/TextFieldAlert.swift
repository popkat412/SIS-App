//
//  TextFieldAlert.swift
//  SIS App
//
//  Created by Wang Yunze on 3/12/20.
//
//  UIAlertController and TextAlert stolen from https://gist.github.com/chriseidhof/cb662d2161a59a0cd5babf78e3562272
// Rest stolen from https://stackoverflow.com/a/57877120/13181476

import Foundation
import SwiftUI
import UIKit

extension UIAlertController {
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
        addTextField {
            $0.placeholder = alert.placeholder
            $0.isSecureTextEntry = alert.isPassword
        }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            alert.action(nil)
        })
        let textField = textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            alert.action(textField?.text)
        })
    }
}

public struct TextAlert {
    var title: String
    var message: String? = nil
    var placeholder: String = ""
    var isPassword: Bool = false
    var accept: String = "OK"
    var cancel: String = "Cancel"

    /// Called when either of the buttons are pressed,
    /// If cancel is pressed then the result is null
    var action: (String?) -> Void
}

func showTextFieldAlert(_ alert: TextAlert) {
    if let controller = topMostViewController() {
        controller.present(UIAlertController(alert: alert), animated: true)
    }
}

private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows.filter { $0.isKeyWindow }.first
}

private func topMostViewController() -> UIViewController? {
    guard let rootController = keyWindow()?.rootViewController else {
        return nil
    }
    return topMostViewController(for: rootController)
}

private func topMostViewController(for controller: UIViewController) -> UIViewController {
    if let presentedController = controller.presentedViewController {
        return topMostViewController(for: presentedController)
    } else if let navigationController = controller as? UINavigationController {
        guard let topController = navigationController.topViewController else {
            return navigationController
        }
        return topMostViewController(for: topController)
    } else if let tabController = controller as? UITabBarController {
        guard let topController = tabController.selectedViewController else {
            return tabController
        }
        return topMostViewController(for: topController)
    }
    return controller
}
