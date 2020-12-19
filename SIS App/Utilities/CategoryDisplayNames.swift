//
//  CategoryNames.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation

/// Data on how to display the names of categories.
/// Gets it data from categories.json file in appubndle
struct CategoryDisplayNames {
    private static var categoryToDisplayName: RawKeyedCodableDictionary<RoomCategory, String>?

    /// Gets the display name of a category
    static func getName(of category: RoomCategory) -> String {
        if categoryToDisplayName == nil {
            initCategoryToDisplayName()
        }

        if let categoryToName = categoryToDisplayName {
            if let name = categoryToName.toDictionary()[category] {
                return name
            } else {
                fatalError("Name not found in dictionary")
            }
        } else {
            fatalError("initCategoryToName() failed")
        }
    }

    private static func initCategoryToDisplayName() {
        categoryToDisplayName = FileUtility.getDataFromJsonAppbundleFile(filename: Constants.categoryToDisplayNameFilename, dataType: RawKeyedCodableDictionary<RoomCategory, String>.self)
    }
}
