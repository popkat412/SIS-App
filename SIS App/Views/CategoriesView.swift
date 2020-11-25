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
        List(Array(categories.keys).sorted(by: { cat1, cat2 in
            cat1.rawValue < cat2.rawValue
        }), id: \.rawValue) { category in
            NavigationLink(destination: RoomsView(
                rooms: categories[category]!,
                categoryName: CategoryNames.getName(of: category)
            )) {
                HStack {
                    Image(category.rawValue)
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("\(CategoryNames.getName(of: category))")
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
