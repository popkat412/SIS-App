//
//  Room.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import Foundation

struct Room: Decodable, Identifiable {
    var name: String
    var level: Int
    var id: String
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
