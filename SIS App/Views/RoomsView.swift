//
//  RoomsView.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import SwiftUI

struct RoomsView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @Environment(\.onRoomSelection) var onRoomSelection

    var rooms: [Room]
    var categoryName: String

    var body: some View {
        List {
            ForEach(roomSections()) { level in
                Section(header: Text("Level \(level.level)")) {
                    ForEach(level.rooms.sorted(by: { room1, room2 in
                        room1.name < room2.name
                    })) { room in
                        Button(
                            action: {
                                playCheckInOutSound()
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
    }

    private func roomSections() -> [Level] {
        var levels = [Int: Level]()

        var uniqueLevelNums: Set<Int> = []
        for room in rooms {
            uniqueLevelNums.insert(room.level)
        }

        for i in uniqueLevelNums {
            levels[i] = Level(rooms: [], level: i)
        }

        for room in rooms {
            levels[room.level]?.rooms.append(room)
        }

        let toReturn = Array(levels.values).sorted { level1, level2 in
            level1.level < level2.level
        }

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
