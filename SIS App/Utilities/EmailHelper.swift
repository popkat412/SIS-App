//
//  EmailHelper.swift
//  SIS App
//
//  Created by Wang Yunze on 4/12/20.
//

import FirebaseFunctions
import Foundation

struct EmailHelper {
    static func sendEmail(data: NSArray, completion: @escaping (Error?) -> Void) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            completion(nil)
//        }
        Functions.functions().httpsCallable(Constants.sendEmailCloudFunction).call(data) { result, error in
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
}
