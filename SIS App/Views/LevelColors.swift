//
//  LevelColors.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import SwiftUI

struct LevelColors {
    static private var levelToColor: [Int: Color]?
    
    static func getColor(for level: Int) -> Color {
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
        var red, green, blue, opacity: Double
        
        func toSwiftUIColor() -> Color {
            Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
        }
    }
    
    static private func initColors() {
        if let filepath = Bundle.main.path(forResource: "colors.json", ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)

                if let contentsData = contents.data(using: .utf8) {
                    let temp = try JSONDecoder().decode([Int: MyColor].self, from: contentsData)
                    
                    levelToColor = [Int: Color]()
                    for (key, value) in temp {
                        levelToColor![key] = value.toSwiftUIColor()
                    }
                }
            } catch {
                print(error)
            }
        } else {
            print("data.json not found :O")
        }
    }
}
