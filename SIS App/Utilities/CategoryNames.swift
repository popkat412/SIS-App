//
//  CategoryNames.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation

struct CategoryNames {
    private static var categoryToName: RawKeyedCodableDictionary<RoomCategory, String>?

    static func getName(of category: RoomCategory) -> String {
        if categoryToName == nil {
            initCategoryToName()
        }

        if let categoryToName = categoryToName {
            if let name = categoryToName.toDictionary()[category] {
                return name
            } else {
                fatalError("Name not found in dictionary")
            }
        } else {
            fatalError("initCategoryToName() failed")
        }
    }

    private static func initCategoryToName() {
        if let filepath = Bundle.main.path(forResource: "categories.json", ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)

                if let contentsData = contents.data(using: .utf8) {
                    categoryToName = try JSONDecoder().decode(RawKeyedCodableDictionary<RoomCategory, String>.self, from: contentsData)
                }
            } catch {
                print(error)
            }
        } else {
            print("data.json not found :O")
        }
    }
}
