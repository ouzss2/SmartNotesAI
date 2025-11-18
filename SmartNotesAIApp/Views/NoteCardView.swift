//
//  NoteCardView.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//
import SwiftUI


struct NoteCardView: View {
    let note: Note
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    } else {
                        Text("No content")
                            .font(.body)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(note.dateModified, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !note.content.isEmpty {
                        Text("\(note.content.count) chars")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await notesViewModel.deleteNote(note)
                }
            }
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }
}
