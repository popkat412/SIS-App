//
//  RoomParentInfo.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import Foundation

struct RoomParentInfo {
    private static var roomIdToParent: [String: String]?

    static func getParent(of room: Room) -> String {
        if roomIdToParent == nil {
            initRoomIdToParent()
        }

        if let roomIdToParent = roomIdToParent {
            if let parent = roomIdToParent[room.id] {
                return parent
            } else {
                // JSON file is not up to date
                initRoomIdToParent(forceRegenerate: true)
                return getParent(of: room)
            }
        } else {
            fatalError("initRoomIdToParent() failed")
        }
    }

    private static func initRoomIdToParent(forceRegenerate: Bool = false) {
        print("initRoomIdToParent, forceRegenerate: \(forceRegenerate)")

        if !forceRegenerate {
            roomIdToParent = FileUtility.getDataFromJsonFile(filename: Constants.roomIdToParentFilename, dataType: [String: String].self)
            if roomIdToParent != nil { return }
        }

        // Precompute the data
        roomIdToParent = [String: String]()
        for block in DataProvider.getBlocks() {
            for (_, rooms) in block.categories {
                for room in rooms {
                    roomIdToParent![room.id] = block.name
                }
            }
        }

        // Store precomputed data in json
        FileUtility.saveDataToJsonFile(filename: Constants.roomIdToParentFilename, data: roomIdToParent)
    }
}
