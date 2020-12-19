//
//  FileUtility.swift
//  SIS App
//
//  Created by Wang Yunze on 24/11/20.
//

import Foundation

struct FileUtility {
    // MARK: API

    /// Get data from a JSON file saved to the documents directory
    static func getDataFromJsonFile<T: Decodable>(filename: String, dataType _: T.Type) -> T? {
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

    /// Get data from JSON file in the appbundle
    static func getDataFromJsonAppbundleFile<T: Decodable>(filename: String, dataType _: T.Type) -> T? {
        if let filepath = Bundle.main.path(forResource: filename, ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)

                if let contentsData = contents.data(using: .utf8) {
                    let result = try JSONDecoder().decode(T.self, from: contentsData)
                    return result
                }

            } catch {
                print(error)
            }
        } else {
            print("\(filename) not found :O")
        }
        return nil
    }

    /// Save data to a JSON file in the documents directory
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

    /// Delete a file in the documents directory
    static func deleteFile(filename: String) {
        do {
            try FileManager.default.removeItem(at: getURLFromFilename(filename))
        } catch {
            print("❌ could not delete file \(filename) ☹️: \(error)")
        }
    }

    // MARK: Helper Methods

    /// Get the URL for a filename, using app groups
    static func getURLFromFilename(_ filename: String) -> URL {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)!
        print("📂 App Group container path: \(url)")
        return url.appendingPathComponent(filename)
    }

    /// Get the path as string for a filename, using app groups
    static func getPathFromFilename(_ filename: String) -> String {
        getURLFromFilename(filename).path
    }
}
