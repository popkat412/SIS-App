//
//  MyErrorInfo.swift
//  SIS App
//
//  Created by Wang Yunze on 2/12/20.
//

import Foundation

struct MyErrorInfo: Identifiable {
    var error: Error
    var id = UUID()

    init(_ error: Error) {
        self.error = error
    }
}
