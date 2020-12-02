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
        title: Text("Whoops! An error occured"),
        message: Text(error.error.localizedDescription),
        dismissButton: .default(Text("Got it!"), action: dismissAction)
    )
}
