//
//  AuthViewModel.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//
import Foundation
import FirebaseAuth
import Combine
import UIKit

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    var isSignedIn: Bool {
        return user != nil
    }
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isLoading = false
            }
        }
    }
    
    @MainActor
    func signInWithGoogle(presenting: UIViewController) async {
        do {
            let result = try await AuthService.shared.signInWithGoogle()
            self.user = result.user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
