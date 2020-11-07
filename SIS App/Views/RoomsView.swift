//
//  RoomsView.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import SwiftUI

struct RoomsView: View {
    var rooms: [Room]
    
    var body: some View {
        Text("RoomsView")
    }
}

struct RoomsView_Previews: PreviewProvider {
    static var previews: some View {
        RoomsView(rooms: [
            Room(name: "Class 1A", level: 1, id: "ABC")
        ])
    }
}
