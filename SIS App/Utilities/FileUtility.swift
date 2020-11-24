//
//  FileUtility.swift
//  SIS App
//
//  Created by Wang Yunze on 24/11/20.
//

import Foundation

struct FileUtility {
    // MARK: API
    static func getDataFromJsonFile<T: Decodable>(filename: String, dataType: T.Type) -> T? {
        if FileManager.default.fileExists(atPath: getPathFromFilename(filename)) {
            print("📂✅ \(filename) exisists :)")
            
            // 1. Get file contents
            var fileContents = ""
            do {
                fileContents = try String(contentsOf: getURLFromFilename(filename))
            } catch {
                print("❌ could not read string from file \(filename) 0_o: \(error)")
                return nil
            }
            
            // 2. De-serialize json
            do {
                return try JSONDecoder().decode(T.self, from: fileContents.data(using: .utf8)!)
            } catch {
                print("❌ could not de-serialize json from file \(filename) ☹️: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func saveDataToJsonFile<T: Encodable>(filename: String, data: T) {
        var toWrite: Data!
        do {
            toWrite = try JSONEncoder().encode(data)
        } catch {
            print("❌ error serializing \(filename) to json \(error)")
            return
        }
        
        // 2. Write that json to file
        do {
            try toWrite.write(to: getURLFromFilename(filename))
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("❌ oops, failed to \(filename) ☹️ \(error)")
            return
        }
    }
    
    static func deleteFile(filename: String) {
        do {
            try FileManager.default.removeItem(at: getURLFromFilename(filename))
        } catch {
            print("❌ could not delete file \(filename) ☹️: \(error)")
        }
    }
    
    // MARK: Helper Methods
    static func getURLFromFilename(_ filename: String) -> URL {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)!
        print("📂 App Group container path: \(url)")
        return url.appendingPathComponent(filename)
    }
    
    static func getPathFromFilename(_ filename: String) -> String {
        getURLFromFilename(filename).path
    }
}
