//
//  SearchView.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import SwiftUI
import SwiftUIX

struct SearchView: View {
    @EnvironmentObject var checkInManager: CheckInManager
    @Environment(\.onRoomSelection) var onRoomSelection
    @State private var searchStr = "";
    @Binding var showingSearch: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button("Back") {
                    showingSearch = false
                }
                CocoaTextField("Search", text: $searchStr)
                    .isFirstResponder(true)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(white: 0.7), lineWidth: 2)
                    )
            }
            .padding(.horizontal)
            
            List(DataProvider.getRoomsFromSearch(searchStr)) { room in
                Button(action: {
                    showingSearch = false
                    onRoomSelection(room)
                }, label: {
                    RoomRow(room: room)
                })
            }
        }
        .padding(.vertical)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(showingSearch: .constant(true))
            .environmentObject(CheckInManager())
    }
}
