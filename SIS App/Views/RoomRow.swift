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
    var showRoomIcon = true
    var showRoomId = true
    var showRoomParent = true

    var body: some View {
        HStack {
            if showLevelIcon {
                LevelIcon(level: room.level)
            }
            if showRoomIcon {
                IconView(room.iconName)
            }
            Text("\(room.name)")
            Spacer()
            if showRoomId {
                Text("\(room.id)")
                    .foregroundColor(.gray)
            }
            if showRoomId && showRoomParent {
                Text("-").foregroundColor(.gray)
            }
            if showRoomParent {
                Text("\(RoomParentInfo.getParent(of: room))")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RoomRow_Previews: PreviewProvider {
    static var previews: some View {
        RoomRow(
            room: Room("Class 1A")
        )
    }
}
