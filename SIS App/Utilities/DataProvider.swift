//
//  DataProvider.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import CoreLocation
import Foundation

/// Provides all the room data, from a file called "rooms.json" in the appbundle
struct DataProvider {
    private static var blocks: [Block]?
    private static var rooms: [Room]?

    /// The placeholder blocks, for debugging / widget placeholder etc...
    static var placeholderBlocks: [Block] {
        [
            Block("Raja Block"),
            Block("Yusof Ishak Block"),
            Block("Sheares Block"),
            Block("Marshall Block"),
        ]
    }

    /// Get the blocks, sorted by the user's location
    /// If the location is nil, then it is sorted alphabetically instead
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

    /// Get a `Block` from a name
    static func getBlock(name: String) -> Block? {
        if blocks == nil {
            blocks = initBlocks()!
        }

        return blocks!.first { $0.name == name }
    }

    /// Get a `Block` from an id
    static func getBlock(id: String) -> Block? {
        if blocks == nil { blocks = initBlocks()! }

        return blocks!.first { $0.id == id }
    }

    /// Get a `Room` from an id
    static func getRoom(id: String) -> Room? {
        if rooms == nil { rooms = initRooms() }

        return rooms!.first { $0.id == id }
    }

    /// Get a `CheckInTarget` from an id.
    /// So this could either be a room or a block
    static func getTarget(id: String) -> CheckInTarget? {
        if let blockTarget = getBlock(id: id) { return blockTarget }
        if let roomTarget = getRoom(id: id) { return roomTarget }
        return nil
    }

    /// Gets a list of rooms from a search query.
    /// Rooms are sorted alphabetically
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
