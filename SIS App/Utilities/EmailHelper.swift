//
//  EmailHelper.swift
//  SIS App
//
//  Created by Wang Yunze on 4/12/20.
//

import FirebaseFunctions
import Foundation

struct EmailHelper {
    /// By confirmation email i mean an email that is sent to a person in charge that will confirm if the person is trolling or not
    /*
        static func sendConfirmationEmail(data: [CheckInSession], completion: @escaping (Error?) -> Void) {
            print(" 🔥 send confirmation email data: \(data)")

            Functions.functions().httpsCallable(Constants.sendConfirmationEmailCloudFunction).call(data.toFirebaseData()) { result, error in
                if let error = error {
                    print("🔥 firebase function error: \(error)")
                    completion(error)
                    return
                }

                if let result = result {
                    print("🔥 firebase function result: \(result)")
                    completion(nil)
                }
            }
        }
     */

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
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
