//
//  CheckInTarget.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import Foundation

protocol CheckInTarget: Codable {
    var name: String { get }
    var id: String { get }
}

struct UnknownCheckInTarget: CheckInTarget {
    var name = "Unknown check in target :("
    var id: String { name }
}
