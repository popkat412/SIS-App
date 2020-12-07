//
//  UserUploadedData.swift
//  SIS App
//
//  Created by Wang Yunze on 6/12/20.
//

import Foundation

struct UserUploadedData {
    var userId: String
    var dateAdded: Date
    var history: [CheckInSession]
}
