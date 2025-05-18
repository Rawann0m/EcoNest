//
//  Message.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 15/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let fromId: String
    let toId: String
    let content: [String]
    let timestamp: Timestamp?
    
    init(documentId: String, data: [String: Any]){
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.content = data["content"] as? [String] ?? []
        self.id = documentId
        self.timestamp = data["timestamp"] as? Timestamp
    }
}
