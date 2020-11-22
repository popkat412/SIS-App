//
//  Block.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import Foundation
import CoreLocation

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
    
    init(name: String) {
        self.name = name
        self.location = Location(longitude: 0, latitude: 0)
        self.radius = 1
        self.categories = [RoomCategory: [Room]]()
    }
}
