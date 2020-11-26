//
//  Room.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import Foundation

struct Room: Decodable, Identifiable, CheckInTarget {
    var name: String
    var level: Int
    var id: String
    var iconName: String

    init(name: String, level: Int, id: String, iconName: String? = nil) {
        self.name = name
        self.level = level
        self.id = id
        self.iconName = iconName ?? ""
    }

    init(_ name: String) {
        self.name = name
        level = 1
        id = "0000"
        iconName = ""
    }
}

enum RoomCategory: String, Decodable {
    case classroom
    case computerLab, scienceLab, music, humanities
    case lectureTheatre
    case projectRoom, combinedRoom
    case staffRoom, administration
    case store
    case others
}
