//
//  RoomsView.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import SwiftUI

struct RoomsView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @Environment(\.onTargetSelection) var onRoomSelection

    var rooms: [Room]
    var categoryName: String

    var body: some View {
        List {
            ForEach(roomSections()) { level in
                Section(header: Text("Level \(level.level)")) {
                    ForEach(level.rooms.sorted { $0.name < $1.name }) { room in
                        Button(
                            action: {
                                onRoomSelection(room)
                            }, label: {
                                RoomRow(
                                    room: room,
                                    showLevelIcon: false,
                                    showRoomId: true,
                                    showRoomParent: false
                                )
                            }
                        )
                    }
                }
            }
        }
        .navigationBarTitle(categoryName, displayMode: .inline)
        .onAppear {
            prepareHaptics()
        }
    }

    private func roomSections() -> [Level] {
        var levels = [Int: Level]()
        let uniqueRooms = rooms.uniqueRooms()

        var uniqueLevelNums: Set<Int> = []
        for room in uniqueRooms {
            uniqueLevelNums.insert(room.level)
        }

        for level in uniqueLevelNums {
            levels[level] = Level(rooms: [], level: level)
        }

        for room in uniqueRooms {
            levels[room.level]?.rooms.append(room)
        }

        let toReturn = Array(levels.values).sorted { $0.level < $1.level }

        return toReturn
    }
}

struct RoomsView_Previews: PreviewProvider {
    static var previews: some View {
        RoomsView(
            rooms: [
                Room(name: "Class 1A", level: 1, id: "ABC"),
                Room(name: "Class 1B", level: 1, id: "ABC"),
                Room(name: "Class 1C", level: 2, id: "ABC"),
                Room(name: "Class 1D", level: 2, id: "ABC"),
                Room(name: "Class 1E", level: 3, id: "ABC"),
            ],
            categoryName: "Test"
        )
    }
}
