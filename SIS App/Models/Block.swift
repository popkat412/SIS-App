//
//  Block.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import Foundation
import CoreLocation

struct Block: Decodable, CheckInTarget {
    var name: String
    var location: Location
    var radius: Double
    @RawKeyedCodableDictionary var categories: [RoomCategory: [Room]]
}
