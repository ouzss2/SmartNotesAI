//
//  Note.swift
//  SmartNotesAIApp
//
//  Created by Tekup-mac-1 on 17/11/2025.
//

import Foundation
import FirebaseFirestore


struct Note: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var content: String
    var dateCreated: Date
    var dateModified: Date
    var userId: String
    
    init(id: String? = nil, title: String, content: String, userId: String) {
        self.id = id
        self.title = title
        self.content = content
        self.dateCreated = Date()
        self.dateModified = Date()
        self.userId = userId
    }
    
    // Custom coding keys to handle Firestore dates
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case dateCreated
        case dateModified
        case userId
    }
}
