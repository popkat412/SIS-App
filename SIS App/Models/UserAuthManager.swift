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
    var isLoggedIn: Bool { user != nil }

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    func signIn(email: String, password: String, onError: @escaping (Error) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error { onError(error) }
        }
    }

    func signUp(email: String, password: String, onError: @escaping (Error) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if error == nil {
                Auth.auth().signIn(withEmail: email, password: password)
            } else {
                onError(error!)
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
