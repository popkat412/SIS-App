//
//  Block.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import CoreLocation
import Foundation

struct Block: Codable, CheckInTarget {
    var name: String
    var location: Location
    var radius: Double
    @RawKeyedCodableDictionary var categories: [RoomCategory: [Room]]

    init(name: String, location: Location, radius: Double, categories: [RoomCategory: [Room]]) {
        self.name = name
        self.location = location
        self.radius = radius
        self.categories = categories
    }

    init(_ name: String) {
        self.name = name
        location = Location(longitude: 0, latitude: 0)
        radius = 1
        categories = [RoomCategory: [Room]]()
    }
}
