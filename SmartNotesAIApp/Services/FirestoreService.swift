//
//  FirestoreService.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import Foundation
import FirebaseFirestore
import Combine


class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchNotes(userId: String) async throws -> [Note] {
        print("📡 Fetching notes without ordering...")
        
        // Simple query without ordering to avoid index requirement
        let snapshot = try await db.collection("notes")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        var notes = try snapshot.documents.compactMap { document in
            try document.data(as: Note.self)
        }
        
        // Sort manually in code instead of in query
        notes.sort { $0.dateModified > $1.dateModified }
        
        print("✅ Loaded \(notes.count) notes (sorted manually)")
        return notes
    }
    
    func addNote(_ note: Note) async throws {
        print("💾 Saving note: '\(note.title)'")
        let _ = try db.collection("notes").addDocument(from: note)
        print("✅ Note saved successfully")
    }
    
    func updateNote(_ note: Note) async throws {
        guard let noteId = note.id else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing"])
        }
        try db.collection("notes").document(noteId).setData(from: note, merge: true)
    }
    
    func deleteNote(_ note: Note) async throws {
        guard let noteId = note.id else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing"])
        }
        try await db.collection("notes").document(noteId).delete()
    }
}
