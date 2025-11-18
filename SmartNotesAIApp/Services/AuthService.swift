//
//  AuthService.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import UIKit
import Combine
import FirebaseCore

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private init() {}
    
    @MainActor
    func signInWithGoogle() async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found"])
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Get the root view controller internally
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "AuthError", code: -2, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(domain: "AuthError", code: -3, userInfo: [NSLocalizedDescriptionKey: "ID token missing"])
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        return try await Auth.auth().signIn(with: credential)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}
