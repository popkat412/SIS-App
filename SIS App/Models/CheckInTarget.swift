//
//  CheckInTarget.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import Foundation

protocol CheckInTarget: Codable {
    /// The name to display
    var name: String { get }

    /// The actual thing this target will be stored with.
    /// This and the name are two different things becasue
    /// the name might change but the id should never
    var id: String { get }
}

struct UnknownCheckInTarget: CheckInTarget {
    var name = "Unknown check in target :("
    var id: String { name }
}
