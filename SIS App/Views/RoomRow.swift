//
//  RoomRow.swift
//  SIS App
//
//  Created by Wang Yunze on 10/11/20.
//

import SwiftUI

struct RoomRow: View {
    var room: Room
    var showLevelIcon = true
    var showRoomId = false
    var showRoomParent = true
    
    var body: some View {
        HStack {
            if (showLevelIcon) {
                LevelIcon(level: room.level)
            }
            Text("\(room.name)")
            Spacer()
            if (showRoomId) {
                Text("\(room.id)")
                    .foregroundColor(.gray)
            }
            if (showRoomId && showRoomParent) {
                Text("-").foregroundColor(.gray)
            }
            if (showRoomParent) {
                Text("\(RoomParentInfo.getParent(of: room))")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RoomRow_Previews: PreviewProvider {
    static var previews: some View {
        RoomRow(
            room: Room(name: "Class 1A", level: 1, id: "C1-17"),
            showRoomId: true
        )
    }
}
