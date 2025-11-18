//
//  EditNoteView.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import SwiftUI
import FirebaseAuth

struct EditNoteView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    
    let note: Note?
    
    @State private var title: String
    @State private var content: String
    @State private var isSaving = false
    
    init(note: Note?) {
        self.note = note
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Note title...", text: $title)
                    .font(.title2)
                    .padding()
                
                Divider()
                
                TextEditor(text: $content)
                    .font(.body)
                    .padding()
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        guard let userId = authViewModel.user?.uid else { return }
        
        if let existingNote = note {
            // Update existing note
            var updatedNote = existingNote
            updatedNote.title = title
            updatedNote.content = content
            updatedNote.dateModified = Date()
            
            Task {
                await notesViewModel.updateNote(updatedNote)
                dismiss()
            }
        } else {
            // Create new note
            Task {
                await notesViewModel.addNote(
                    title: title,
                    content: content,
                    userId: userId
                )
                dismiss()
            }
        }
    }
}
