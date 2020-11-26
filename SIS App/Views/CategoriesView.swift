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
        List(Array(categories.keys).sorted(by: {
            $0.rawValue < $1.rawValue
        }), id: \.rawValue) { category in
            NavigationLink(destination: RoomsView(
                rooms: categories[category]!,
                categoryName: CategoryDisplayNames.getName(of: category)
            )) {
                HStack {
                    IconView(category.rawValue)
                    Text("\(CategoryDisplayNames.getName(of: category))")
                }
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
                    Room("Class 1A"),
                ],
                .computerLab: [
                    Room("Computer Lab 1"),
                ],
            ],
            blockName: "Test Block"
        )
    }
}
