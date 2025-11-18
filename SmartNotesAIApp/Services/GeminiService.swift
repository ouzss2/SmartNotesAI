//
//  GeminiService.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//
import Foundation
import Combine

class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    
    private let apiKey = "AIzaSyDAy6YW-7yOG7q6Obgt8lZpMN13wlOqoVg"
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    private init() {}
    
    func generateContent(prompt: String) async throws -> String {
        // Check if API key is set
        guard apiKey != "YOUR_GEMINI_API_KEY", !apiKey.isEmpty else {
            throw NSError(domain: "GeminiError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Please add your Gemini API key in GeminiService.swift"
            ])
        }
        
        let urlString = "\(baseURL)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Correct request body format for Gemini API
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🌐 Making Gemini API request to: \(urlString)")
        print("📤 Request body: \(requestBody)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        print("📥 HTTP Status: \(httpResponse.statusCode)")
        
        // Print response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Raw response: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorInfo = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            throw NSError(domain: "GeminiError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorInfo?["error"] ?? "Unknown error")"
            ])
        }
        
        // Parse response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let candidates = json?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            
            print("❌ Failed to parse response: \(json ?? [:])")
            throw NSError(domain: "GeminiError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to parse Gemini response"
            ])
        }
        
        print("✅ Gemini response parsed successfully")
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func summarizeText(_ text: String) async throws -> String {
        let prompt = """
        Please summarize the following text into 3-5 clear, concise bullet points:
        
        "\(text)"
        
        Return only the bullet points without any additional text.
        """
        return try await generateContent(prompt: prompt)
    }
    
    func improveWriting(_ text: String) async throws -> String {
        let prompt = """
        Rewrite the following text to be more clear, professional, and well-structured while preserving the original meaning:
        
        "\(text)"
        
        Return only the improved version without any additional commentary.
        """
        return try await generateContent(prompt: prompt)
    }
    
    func generateIdeas(_ text: String) async throws -> String {
        let prompt = """
        Based on the following text, generate 5 creative ideas or suggestions for expansion. Present each idea in one concise line:
        
        "\(text)"
        
        Return only the numbered ideas without any additional text.
        """
        return try await generateContent(prompt: prompt)
    }
}
