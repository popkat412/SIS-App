//
//  Array+UniqueRooms.swift
//  SIS App
//
//  Created by Wang Yunze on 8/12/20.
//

import Foundation

extension Array where Element == Room {
    /// This is to deal with rooms like RDS which take up more than one unit number
    /// This considers the rooms to be the same so long as their names are the same
    /// NOT the IDs.
    func uniqueRooms() -> [Room] {
        var temp = [Room]()
        var added: Set<String> = []
        for element in self {
            if !added.contains(element.name) {
                added.insert(element.name)
                temp.append(element)
            }
        }
        return temp
    }
}
