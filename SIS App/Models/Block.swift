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
}
