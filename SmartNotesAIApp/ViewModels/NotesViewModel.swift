//
//  NotesViewModel.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//
import Foundation
import Combine

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let firestoreService = FirestoreService.shared
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func loadNotes(userId: String) async {
        print("🚀 NotesViewModel.loadNotes() called with userId:", userId)
        isLoading = true
        
        do {
            print("📡 Fetching notes from Firestore...")
            notes = try await firestoreService.fetchNotes(userId: userId)
            print("✅ Successfully loaded \(notes.count) notes")
            
            if notes.isEmpty {
                print("ℹ️ No notes found for this user")
            } else {
                print("📋 Loaded notes:")
                for (index, note) in notes.enumerated() {
                    print("   \(index + 1). '\(note.title)' - '\(note.content.prefix(30))...'")
                }
            }
        } catch {
            print("❌ Error loading notes:", error)
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
        }
        
        isLoading = false
        print("🏁 Finished loading notes")
    }
    
    func addNote(title: String, content: String, userId: String) async {
        print("➕ Adding new note...")
        let note = Note(title: title, content: content, userId: userId)
        
        do {
            try await firestoreService.addNote(note)
            print("✅ Note saved to Firestore, now reloading...")
            await loadNotes(userId: userId)
        } catch {
            print("❌ Error adding note:", error)
            errorMessage = "Failed to add note: \(error.localizedDescription)"
        }
    }
    
    func updateNote(_ note: Note) async {
        do {
            try await firestoreService.updateNote(note)
            await loadNotes(userId: note.userId)
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
    }
    
    func deleteNote(_ note: Note) async {
        do {
            try await firestoreService.deleteNote(note)
            await loadNotes(userId: note.userId)
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
        }
    }
}
