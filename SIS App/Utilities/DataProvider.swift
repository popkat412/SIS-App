//
//  DataProvider.swift
//  SIS App
//
//  Created by Wang Yunze on 9/11/20.
//

import Foundation

struct DataProvider {
    private static var blocks: [Block]?
    
    static func getBlocks() -> [Block] {
        if blocks == nil {
            blocks = blocksFromJson()!
        }
        
        return blocks!
    }
    
    private static func blocksFromJson() -> [Block]? {
        if let filepath = Bundle.main.path(forResource: "data.json", ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)
                
                if let contentsData = contents.data(using: .utf8) {
                    let result = try JSONDecoder().decode([Block].self, from: contentsData)
                    return result
                }
                
            } catch {
                print(error)
            }
        } else {
            print("data.json not found :O")
        }
        return nil
    }
}
