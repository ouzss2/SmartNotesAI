import SwiftUI
import FirebaseAuth

struct NotesListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    @State private var showingCreateNote = false
    @State private var searchIsActive = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Modern Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemBackground).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Notes")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("\(notesViewModel.filteredNotes.count) notes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Profile Menu
                            Menu {
                                Button {
                                    loadNotes()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Refresh")
                                    }
                                }
                                
                                Button(role: .destructive) {
                                    authViewModel.signOut()
                                } label: {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Sign Out")
                                    }
                                }
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .background(
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Modern Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .font(.system(size: 18, weight: .medium))
                        
                        TextField("Search notes...", text: $notesViewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 17, weight: .regular))
                        
                        if !notesViewModel.searchText.isEmpty {
                            Button(action: {
                                withAnimation(.spring()) {
                                    notesViewModel.searchText = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    
                    // Notes Content
                    if notesViewModel.isLoading {
                        ModernLoadingView()
                    } else if notesViewModel.filteredNotes.isEmpty {
                        ModernEmptyView()
                    } else {
                        ModernNotesGrid()
                    }
                }
                
                // Modern FAB
                ModernFloatingButton {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingCreateNote = true
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateNote) {
                ModernAddNoteView()
            }
            .onAppear {
                loadNotes()
            }
            .refreshable {
                await loadNotesAsync()
            }
        }
    }
    
    private func loadNotes() {
        guard let userId = authViewModel.user?.uid else { return }
        Task {
            await notesViewModel.loadNotes(userId: userId)
        }
    }
    
    private func loadNotesAsync() async {
        guard let userId = authViewModel.user?.uid else { return }
        await notesViewModel.loadNotes(userId: userId)
    }
}

// MARK: - Modern Subviews

struct ModernNotesGrid: View {
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(notesViewModel.filteredNotes) { note in
                    NavigationLink {
                        NoteDetailView(note: note)
                    } label: {
                        ModernNoteCard(note: note)
                    }
                    .buttonStyle(ModernCardButtonStyle())
                }
            }
            .padding(20)
        }
    }
}

struct ModernNoteCard: View {
    let note: Note
    @EnvironmentObject var notesViewModel: NotesViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    } else {
                        Text("No content")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Footer
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(note.dateModified, style: .date)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                    
                    if !note.content.isEmpty {
                        Text("\(note.content.count) chars")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // AI Badge if content exists
                if !note.content.isEmpty {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(6)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
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
            Text("Are you sure you want to delete \"\(note.title.isEmpty ? "Untitled" : note.title)\"?")
        }
    }
}

struct ModernEmptyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("No Notes Yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Create your first note and unlock AI-powered writing tools")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ModernLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.blue)
            
            VStack(spacing: 8) {
                Text("Loading Notes")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Getting your thoughts organized...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ModernFloatingButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(24)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Modern Add Note View
import SwiftUI

struct ModernAddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    @State private var title = ""
    @State private var content = ""
    @State private var isSaving = false
    @State private var showAIQuickActions = false
    @State private var characterCount = 0
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Main Content
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header with character count
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Note")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    if characterCount > 0 {
                                        Text("\(characterCount) characters")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Spacer()
                                
                                // Quick AI Actions Toggle
                                Button {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showAIQuickActions.toggle()
                                    }
                                } label: {
                                    Image(systemName: showAIQuickActions ? "sparkles" : "sparkles.slash")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(showAIQuickActions ? .orange : .gray)
                                        .padding(12)
                                        .background(showAIQuickActions ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                            
                            // Title Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "textformat.size")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("TITLE")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.blue)
                                        .textCase(.uppercase)
                                    
                                    Spacer()
                                    
                                    if !title.isEmpty {
                                        Button("Clear") {
                                            withAnimation(.spring()) {
                                                title = ""
                                            }
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.red)
                                    }
                                }
                                
                                TextField("What's this note about?", text: $title)
                                    .font(.system(size: 24, weight: .bold))
                                    .focused($focusedField, equals: .title)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .content
                                    }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                            
                            // Content Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("CONTENT")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.purple)
                                        .textCase(.uppercase)
                                    
                                    Spacer()
                                    
                                    if !content.isEmpty {
                                        Button("Clear") {
                                            withAnimation(.spring()) {
                                                content = ""
                                                characterCount = 0
                                            }
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.red)
                                    }
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $content)
                                        .font(.system(size: 18, weight: .regular))
                                        .focused($focusedField, equals: .content)
                                        .frame(minHeight: 300)
                                        .onChange(of: content) { newValue in
                                            characterCount = newValue.count
                                        }
                                    
                                    if content.isEmpty {
                                        Text("Start writing your thoughts...\n\n💡 Tip: Add content to unlock AI tools")
                                            .font(.system(size: 18, weight: .regular))
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                            .padding(.leading, 5)
                                            .allowsHitTesting(false)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, showAIQuickActions ? 160 : 100)
                        }
                    }
                }
                
                // AI Quick Actions Panel
                if showAIQuickActions && !content.isEmpty {
                    AIQuickActionsPanel(content: $content)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Save Button
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        // Draft Status
                        if !title.isEmpty || !content.isEmpty {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                                Text("Draft")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Spacer()
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                if !title.isEmpty || !content.isEmpty {
                                    // Show confirmation dialog
                                    showCancelConfirmation()
                                } else {
                                    dismiss()
                                }
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)
                            
                            Button {
                                saveNote()
                            } label: {
                                if isSaving {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark")
                                        Text("Save")
                                    }
                                }
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .opacity(canSave ? 1.0 : 0.3)
                            )
                            .clipShape(Capsule())
                            .disabled(!canSave)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .onAppear {
            // Auto-focus title field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .title
            }
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !isSaving
    }
    
    private func saveNote() {
        guard let userId = authViewModel.user?.uid else { return }
        
        isSaving = true
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        Task {
            await notesViewModel.addNote(
                title: title.trimmingCharacters(in: .whitespaces),
                content: content.trimmingCharacters(in: .whitespaces),
                userId: userId
            )
            
            await MainActor.run {
                isSaving = false
                
                // Success haptic
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                
                dismiss()
            }
        }
    }
    
    private func showCancelConfirmation() {
        // You can implement a proper alert here
        // For now, just dismiss
        dismiss()
    }
}

// MARK: - AI Quick Actions Panel
struct AIQuickActionsPanel: View {
    @Binding var content: String
    @State private var aiResult = ""
    @State private var isAILoading = false
    @State private var selectedAction: String? = nil
    
    let quickActions = [
        ("Summarize", "text.badge.checkmark", Color.blue),
        ("Improve", "wand.and.stars", Color.purple),
        ("Expand", "arrow.left.and.right", Color.green),
        ("Simplify", "scissors", Color.orange),
        ("Formal", "briefcase", Color.indigo)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.orange)
                Text("AI Quick Actions")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Tap to apply")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickActions, id: \.0) { action, icon, color in
                        AIQuickActionButton(
                            title: action,
                            icon: icon,
                            color: color,
                            isLoading: isAILoading && selectedAction == action
                        ) {
                            selectedAction = action
                            performAIAction(action)
                        }
                    }
                }
            }
            
            if !aiResult.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("AI Result")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Apply") {
                            content = aiResult
                            aiResult = ""
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                    }
                    
                    Text(aiResult)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 80)
    }
    
    private func performAIAction(_ action: String) {
        isAILoading = true
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAILoading = false
            
            switch action {
            case "Summarize":
                aiResult = "• Key point 1\n• Important finding\n• Main conclusion"
            case "Improve":
                aiResult = "This is an enhanced version of your text with improved clarity and professional tone."
            case "Expand":
                aiResult = "Your original text has been expanded with additional details and examples for better understanding."
            case "Simplify":
                aiResult = "A simplified version that maintains the core message while being more concise."
            case "Formal":
                aiResult = "A formal rendition of your content suitable for professional contexts."
            default:
                aiResult = "AI processing complete."
            }
        }
    }
}

// MARK: - AI Quick Action Button
struct AIQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(color)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(width: 70, height: 70)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    ModernAddNoteView()
        .environmentObject(AuthViewModel())
        .environmentObject(NotesViewModel())
}

// MARK: - Modern UI Components

struct AIFeatureChip: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(title)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct ModernCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NotesListView()
        .environmentObject(AuthViewModel())
        .environmentObject(NotesViewModel())
}
