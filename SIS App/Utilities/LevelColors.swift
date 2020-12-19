//
//  LevelColors.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import SwiftUI

struct LevelColors {
    typealias LevelColor = (background: Color, text: Color)
    typealias LevelToColor = [Int: LevelColor]

    private static var levelToColor: LevelToColor?

    /// Get the color for a level
    /// This info is inside a file called "colors.json" inside the appbundle
    static func getColor(for level: Int) -> LevelColor {
        if levelToColor == nil {
            initColors()
        }

        if let levelToColor = levelToColor {
            if let color = levelToColor[level] {
                return color
            } else {
                fatalError("Level not found in dictionary")
            }
        } else {
            fatalError("initColors() failed")
        }
    }

    private struct MyColor: Decodable {
        var red, green, blue, opacity, text_color: Double

        func toSwiftUIColor() -> Color {
            Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
        }
    }

    private static func initColors() {
        let temp = FileUtility.getDataFromJsonAppbundleFile(filename: Constants.levelColorsFilename, dataType: [Int: MyColor].self)
        if let temp = temp {
            levelToColor = LevelToColor()
            for (key, value) in temp {
                levelToColor![key] = (
                    background: value.toSwiftUIColor(),
                    text: value.text_color == 0 ? .black : .white
                )
            }
        }
    }
}
