//
//  CategoriesView.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import SwiftUI

struct CategoriesView: View {
    var categories: [RoomCategory: [Room]]
    var blockName: String
    
    var body: some View {
        List(Array(categories.keys), id: \.rawValue) { category in
            NavigationLink(destination: RoomsView(rooms: categories[category]!)) {
                Text("\(CategoryNames.getName(of: category))")
            }
        }
        .navigationBarTitle(blockName, displayMode: .inline)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView(
            categories: [
                .classroom: [
                    Room(name: "Class 1A", level: 1, id: "ABC")
                ],
                .computerLab: [
                    Room(name: "Computer Lab 1", level: 2, id: "DEF")
                ]
            ],
            blockName: "Test Block"
        )
    }
}
