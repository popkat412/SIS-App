//
//  Room.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import Foundation

struct Room: Decodable {
    var name: String
    var level: Int
    var id: String
}

enum RoomCategory: String, Decodable {    
    case computerLab      // = "Computer Lab"
    case classroom        // = "Classroom"
    case lectureTheatre   // = "Lecture Theatre"
    case scienceLab       // = "Science Lab"
    case projectRoom      // = "Project Room"
    case staffRoom        // = "Staff Room"
    case combinedRoom     // = "Combined Room"
    case others           // = "Others"
}
