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
    
//    enum CodingKeys: String, CodingKey {
//        case computerLab
//        case classroom
//        case lectureTheatre
//        case scienceLab
//        case projectRoom
//        case staffRoom
//        case combinedRoom
//        case others
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        print("Coding Path: \(container.codingPath)")
//        print("Container: \(container)")
//
//        self = .others
//
//        let value = try container.decode()
//
//        switch value {
//        case "computerLab":
//            self = .computerLab
//        case "classroom":
//            self = .classroom
//        case "lectureTheatre":
//            self = .lectureTheatre
//        case "scienceLab":
//            self = .scienceLab
//        case "projectRoom":
//            self = .projectRoom
//        case "staffRoom":
//            self = .staffRoom
//        case "combinedRoom":
//            self = .combinedRoom
//        default:
//            self = .others
//        }
//    }
}
