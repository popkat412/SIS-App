//
//  MyErrorInfo.swift
//  SIS App
//
//  Created by Wang Yunze on 2/12/20.
//

import Foundation

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
}
