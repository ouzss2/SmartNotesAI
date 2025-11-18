//
//  LoginView.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import SwiftUI

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSigningIn = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 20) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("SmartNotes AI")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your intelligent note-taking companion")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Features list
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "sparkles", text: "AI-powered summarization")
                    FeatureRow(icon: "wand.and.stars", text: "Smart writing improvements")
                    FeatureRow(icon: "lightbulb", text: "Creative idea generation")
                    FeatureRow(icon: "cloud", text: "Sync across all your devices")
                }
                .padding()
                
                Spacer()
                
                // Sign in button
                VStack(spacing: 16) {
                    if isSigningIn {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                    } else {
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                            isSigningIn = true
                            Task {
                                await performGoogleSignIn()
                            }
                        }
                        .frame(height: 50)
                    }
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Footer
                Text("Sign in with your Google account to get started")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func performGoogleSignIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        await authViewModel.signInWithGoogle(presenting: rootViewController)
        isSigningIn = false
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.white)
                .font(.body)
            
            Spacer()
        }
    }
}
