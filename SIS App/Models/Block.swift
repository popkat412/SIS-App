//
//  Block.swift
//  SIS App
//
//  Created by Wang Yunze on 3/11/20.
//

import Foundation

struct Block: Decodable {
    var name: String
    var categories: RawKeyedDecodableDictionary<RoomCategory, [Room]>
}
