//
//  GeminiViewModel.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import Foundation
import Combine
import Foundation

@MainActor
class GeminiViewModel: ObservableObject {
    @Published var result: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let geminiService = GeminiService.shared
    
    func performAction(_ action: GeminiAction, on text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to process"
            return
        }
        
        isLoading = true
        errorMessage = nil
        result = ""
        
        do {
            switch action {
            case .summarize:
                result = try await geminiService.summarizeText(text)
            case .improve:
                result = try await geminiService.improveWriting(text)
            case .ideas:
                result = try await geminiService.generateIdeas(text)
            }
        } catch {
            errorMessage = "AI service error: \(error.localizedDescription)"
            print("Gemini API error: \(error)")
        }
        
        isLoading = false
    }
    
    func clearResult() {
        result = ""
        errorMessage = nil
    }
}

enum GeminiAction {
    case summarize
    case improve
    case ideas
}
