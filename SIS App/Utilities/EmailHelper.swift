//
//  EmailHelper.swift
//  SIS App
//
//  Created by Wang Yunze on 4/12/20.
//

import FirebaseFunctions
import Foundation

struct EmailHelper {
    /// By warning email, I mean a email sent to the user that warns them that they came into contact with an infected person
    static func sendWarningEmail(data: [Intersection], completion: @escaping (Error?) -> Void) {
        print("🔥 send warning email data: \(data)")

        Functions.functions().httpsCallable(Constants.sendWarningEmailCloudFucntion).call(data.toFirebaseData()) { result, error in
            if let error = error {
                completion(error)
                return
            }

            if let result = result {
                print("🔥 send warning email result: \(result.data)")
                completion(nil)
            }
        }
    }
}

extension Array where Element: Encodable {
    func toFirebaseData() -> NSArray {
        let result = map { $0.dictionary! }
        print("🔥 firebase data: \(result), original data: \(self)")
        return result as NSArray
    }
}

extension Encodable {
    /// The [String: Any] version of the Encodable struct
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
