//
//  SearchView.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import SwiftUI
import SwiftUIX

struct LevelIcon: View {
    var level: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LevelColors.getColor(for: level))
            Text("L\(level)")
        }
        .frame(width: 30, height: 30, alignment: .center)
    }
}

struct SearchView: View {
    @EnvironmentObject var checkInManager: CheckInManager
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
                    checkInManager.checkIn(to: room)
                }, label: {
                    HStack {
                        LevelIcon(level: room.level)
                        Text("\(room.name)")
                        Spacer()
                        Text("\(RoomParentInfo.getParent(of: room))")
                            .foregroundColor(.gray)
                    }
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
