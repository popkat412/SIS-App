//
//  OnErrorAlert.swift
//  SIS App
//
//  Created by Wang Yunze on 2/12/20.
//

import Foundation
import SwiftUI

func makeErrorAlert(_ error: MyErrorInfo, dismissAction: (() -> Void)? = nil) -> Alert {
    Alert(
        title: Text("Whoops!"),
        message: Text(error.message),
        dismissButton: .default(Text("Got it!"), action: dismissAction)
    )
}
