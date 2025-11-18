import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @EnvironmentObject var notesViewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var geminiViewModel = GeminiViewModel()
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingReplaceConfirm = false
    @State private var showAIActions = true
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content with Scroll Detection
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Header with Sticky Effect
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .global).minY) { newValue in
                                    scrollOffset = newValue
                                }
                        }
                        .frame(height: 0)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            // Note Header
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.title.isEmpty ? "Untitled Note" : note.title)
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        // Metadata - FIXED: Using Text instead of Label
                                        HStack(spacing: 16) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "calendar")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.blue)
                                                Text("Created: \(formattedDate(note.dateCreated))")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "clock")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.purple)
                                                Text("Modified: \(relativeTime(note.dateModified))")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.purple)
                                            }
                                            
                                            if !note.content.isEmpty {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "text.alignleft")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.orange)
                                                    Text("\(note.content.count) chars")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.orange)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Quick Actions
                                    VStack(spacing: 12) {
                                        Button {
                                            withAnimation(.spring()) {
                                                showAIActions.toggle()
                                            }
                                        } label: {
                                            Image(systemName: showAIActions ? "sparkles" : "sparkles.slash")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(showAIActions ? .orange : .gray)
                                                .padding(10)
                                                .background(showAIActions ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                        
                                        Button {
                                            showingEditSheet = true
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(.blue)
                                                .padding(10)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            
                            // Content Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("CONTENT")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.purple)
                                        .textCase(.uppercase)
                                    
                                    Spacer()
                                    
                                    if !note.content.isEmpty {
                                        Button("Copy All") {
                                            UIPasteboard.general.string = note.content
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.blue)
                                    }
                                }
                                
                                if note.content.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        Text("No content yet")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Button("Add Content") {
                                            showingEditSheet = true
                                        }
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.blue)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(40)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                                } else {
                                    Text(note.content)
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(.primary)
                                        .lineSpacing(8)
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(20)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            
                            // AI Tools Section
                            if !note.content.isEmpty && showAIActions {
                                ModernAIToolsSection()
                                    .id("ai-tools")
                            }
                            
                            // AI Result
                            if !geminiViewModel.result.isEmpty {
                                ModernAIResultSection()
                            }
                            
                            // Error Message
                            if let error = geminiViewModel.errorMessage {
                                ModernErrorSection(error: error)
                            }
                        }
                    }
                }
            }
            
            // Floating Action Bar
            if scrollOffset < -50 {
                FloatingActionBar()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Note")
                        }
                    }
                    
                    Button {
                        UIPasteboard.general.string = note.content
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Content")
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Note")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditNoteView(note: note)
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await notesViewModel.deleteNote(note)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(note.title.isEmpty ? "Untitled" : note.title)\"? This action cannot be undone.")
        }
        .alert("Replace Content", isPresented: $showingReplaceConfirm) {
            Button("Replace", role: .destructive) {
                replaceNoteContent()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will replace your current note content with the AI-generated text.")
        }
    }
    
    // MARK: - Date Formatting Helpers (FIXED)
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Modern AI Tools Section
    @ViewBuilder
    private func ModernAIToolsSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("AI Writing Assistant")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Powered by Gemini")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ModernAIActionButton(
                    title: "Summarize",
                    icon: "text.badge.checkmark",
                    color: .blue,
                    description: "Extract key points",
                    action: {
                        await geminiViewModel.performAction(.summarize, on: note.content)
                    }
                )
                
                ModernAIActionButton(
                    title: "Improve",
                    icon: "wand.and.stars",
                    color: .purple,
                    description: "Enhance writing",
                    action: {
                        await geminiViewModel.performAction(.improve, on: note.content)
                    }
                )
                
                ModernAIActionButton(
                    title: "Brainstorm",
                    icon: "lightbulb",
                    color: .orange,
                    description: "Generate ideas",
                    action: {
                        await geminiViewModel.performAction(.ideas, on: note.content)
                    }
                )
            }
            
            // Additional AI Actions
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ModernAIActionButton(
                    title: "Simplify",
                    icon: "scissors",
                    color: .green,
                    description: "Make concise",
                    action: {
                        // Add simplify action
                        print("Simplify tapped")
                    }
                )
                
                ModernAIActionButton(
                    title: "Formalize",
                    icon: "briefcase",
                    color: .indigo,
                    description: "Professional tone",
                    action: {
                        // Add formalize action
                        print("Formalize tapped")
                    }
                )
            }
            
            if geminiViewModel.isLoading {
                HStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI is thinking...")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Processing your request")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(16)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Modern AI Result Section
    @ViewBuilder
    private func ModernAIResultSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.green)
                
                Text("AI Generated")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Copy") {
                        UIPasteboard.general.string = geminiViewModel.result
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .buttonStyle(.bordered)
                    
                    Button("Use This") {
                        showingReplaceConfirm = true
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear") {
                        geminiViewModel.clearResult()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .buttonStyle(.bordered)
                }
            }
            
            Text(geminiViewModel.result)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.green.opacity(0.05), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Modern Error Section
    @ViewBuilder
    private func ModernErrorSection(error: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text("AI Service Error")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
                Spacer()
                
                Button {
                    geminiViewModel.errorMessage = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
            }
            
            Text(error)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            
            Button("Try Again") {
                geminiViewModel.errorMessage = nil
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.red)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .red.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Floating Action Bar
    @ViewBuilder
    private func FloatingActionBar() -> some View {
        HStack(spacing: 16) {
            Button {
                showingEditSheet = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.bordered)
            
            if !note.content.isEmpty {
                Button {
                    withAnimation(.spring()) {
                        showAIActions = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("AI Tools")
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
            
            Button {
                UIPasteboard.general.string = note.content
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    private func replaceNoteContent() {
        var updatedNote = note
        updatedNote.content = geminiViewModel.result
        updatedNote.dateModified = Date()
        
        Task {
            await notesViewModel.updateNote(updatedNote)
            geminiViewModel.clearResult()
        }
    }
}

// MARK: - Modern AI Action Button
struct ModernAIActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                    .frame(height: 32)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(color.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationView {
        NoteDetailView(note: Note(
            title: "Project Planning",
            content: "We need to develop a new mobile application with AI features. The app should include user authentication, real-time data sync, and intelligent content generation. We'll use SwiftUI for the frontend and Firebase for the backend.",
            userId: "123"
        ))
        .environmentObject(NotesViewModel())
    }
}
