//
//  RoomParentInfo.swift
//  SIS App
//
//  Created by Wang Yunze on 8/11/20.
//

import Foundation

struct RoomParentInfo {
    static private var roomIdToParent: [String: String]?
    
    static func getParent(of room: Room) -> String {
        if roomIdToParent == nil {
            initRoomIdToParent()
        }
        
        if let roomIdToParent = roomIdToParent {
            if let parent = roomIdToParent[room.id] {
                return parent
            } else {
                fatalError("\(room.id) not in dictionary")
            }
        } else {
            fatalError("initRoomIdToParent() failed")
        }
    }
    
    static private func initRoomIdToParent() {
        // Check if precomputed json exisists in documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let jsonFile = documentsDirectory.appendingPathComponent("roomIdToParent.json")
        
        do {
            let savedJson = try String(contentsOf: jsonFile)
            print(savedJson)
            
            let decoder = JSONDecoder()
            if let savedJsonData = savedJson.data(using: .utf8) {
                roomIdToParent = try decoder.decode([String: String].self, from: savedJsonData)
                return
            }
        } catch {
            print("Error reading saved file / saved file doesn't exisist: \(error)")
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
        do {
            let encoder = JSONEncoder()
            let toSave = try encoder.encode(roomIdToParent)
            try toSave.write(to: jsonFile)
        } catch {
            print("error writing to file: \(error)")
        }
        
        
    }
}
