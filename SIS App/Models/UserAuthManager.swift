//
//  UserAuthManager.swift
//  SIS App
//
//  Created by Wang Yunze on 1/12/20.
//

import Firebase
import Foundation

/// Very big class containing everything related to Firebase Auth
class UserAuthManager: ObservableObject {
    /// The current user, is nil when user is not logged in
    @Published var user: User?

    /// Although this is called "isLoggedIn", this is only true if and only if:
    /// 1. The user is logged in
    /// 2. The user is email verified
    var isLoggedIn: Bool { user?.isEmailVerified ?? false }

    /// Convenience getter for user info
    var userEmail: String { user?.email ?? "Unknown Email" }

    /// This sets up the firebase auth state change listener
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            print("🔥 new user: \(String(describing: user?.email)), is verified: \(String(describing: user?.isEmailVerified))")
        }
    }

    // Uh... the rest of the functions are pretty self explanatory I think

    func signIn(email: String, password: String, onError: @escaping OnErrorCallback) {
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

    func signUp(email: String, password: String, onSentEmailVerfication: @escaping () -> Void, onError: @escaping OnErrorCallback) {
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

    func signOut(onError: @escaping OnErrorCallback) {
        do {
            try Auth.auth().signOut()
        } catch {
            onError(error)
        }
    }

    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
}
