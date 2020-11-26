//
//  DataProvider.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import CoreLocation
import Foundation

struct DataProvider {
    private static var blocks: [Block]?
    private static var rooms: [Room]?

    static var placeholderBlocks: [Block] {
        [
            Block("Raja Block"),
            Block("Yusof Ishak Block"),
            Block("Sheares Block"),
            Block("Marshall Block"),
        ]
    }

    static func getBlocks(userLocation: CLLocation? = nil) -> [Block] {
        if blocks == nil {
            blocks = initBlocks()!
        }

        return blocks!.sorted(by: { (block1, block2) -> Bool in
            // If location avaliable, sort by distance to nearest block
            if let dist1 = userLocation?.distance(from: block1.location.toCLLocation()),
               let dist2 = userLocation?.distance(from: block2.location.toCLLocation())
            {
                return dist1 - block1.radius < dist2 - block2.radius
            }

            // Else sort by name
            return block1.name < block2.name
        })
    }

    static func getBlock(name: String) -> Block? {
        if blocks == nil {
            blocks = initBlocks()!
        }

        return blocks!.first { $0.name == name }
    }

    static func getRoomsFromSearch(_ searchStr: String) -> [Room] {
        if rooms == nil {
            rooms = initRooms()
        }

        if searchStr.isEmpty {
            return rooms!.sorted { room1, room2 in
                room1.name < room2.name
            }
        }

        var results = [Room]()

        for room in rooms! {
            if room.name.lowercased().contains(searchStr.lowercased()) {
                results.append(room)
            }
        }

        return results
    }

    // MARK: Private Methods

    private static func initRooms() -> [Room] {
        if blocks == nil {
            blocks = initBlocks()!
        }

        var _rooms = [Room]()

        for block in blocks! {
            for (_, categoryRooms) in block.categories {
                for room in categoryRooms {
                    _rooms.append(room)
                }
            }
        }

        return _rooms
    }

    private static func initBlocks() -> [Block]? {
        FileUtility.getDataFromJsonAppbundleFile(filename: Constants.roomsFilename, dataType: [Block].self)
    }
}
