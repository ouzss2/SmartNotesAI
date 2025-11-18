//
//  SmartNotesAIAppApp.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import SwiftUI
import Firebase

@main
struct SmartNotesAIAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
        @StateObject private var notesViewModel = NotesViewModel()
    init() {
           FirebaseApp.configure() 
       }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(notesViewModel)
                
        }
    }
}
