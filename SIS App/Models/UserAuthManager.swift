//
//  UserAuthManager.swift
//  SIS App
//
//  Created by Wang Yunze on 1/12/20.
//

import Firebase
import Foundation

class UserAuthManager: ObservableObject {
    @Published var user: User?
    var isLoggedIn: Bool { user?.isEmailVerified ?? false }
    var userEmail: String { user?.email ?? "Unknown Email" }

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            print("🔥 new user: \(String(describing: user?.email)), is verified: \(String(describing: user?.isEmailVerified))")
        }
    }

    func signIn(email: String, password: String, onError: @escaping (Error) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                onError(error)
                return
            }

            self.user = result?.user
            print("🔥 is verified: \(String(describing: result?.user.isEmailVerified))")
            if let isVerified = result?.user.isEmailVerified, !isVerified {
                print("🔥 signed in but user isn't verified")
                onError("Your account is not verified, veify by clicking the link sent to \(result?.user.email ?? "Unknown Email")")
            }
        }
    }

    func signUp(email: String, password: String, onSentEmailVerfication: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error { onError(error) }
            else {
                Auth.auth().currentUser?.sendEmailVerification { error in
                    if let error = error { onError(error) }
                    else { onSentEmailVerfication() }
                }
            }
        }
    }

    func signOut(onError: @escaping (Error) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch {
            onError(error)
        }
    }
}
