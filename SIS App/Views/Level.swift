//
//  Level.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation

struct Level: Identifiable {
    var rooms: [Room]
    var level: Int
    var id = UUID()
}
