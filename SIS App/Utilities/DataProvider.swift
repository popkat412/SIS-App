//
//  DataProvider.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import Foundation

struct DataProvider {
    private static var blocks: [Block]?
    private static var rooms: [Room]?

    static func getBlocks() -> [Block] {
        if blocks == nil {
            blocks = initBlocks()!
        }

        return blocks!
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
