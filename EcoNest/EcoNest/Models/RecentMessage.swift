//
//  RecentMessage.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 15/11/1446 AH.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct RecentMessage: Identifiable, Codable {
    var id: String?
    let content: [String]
    let toId: String
    let fromId: String
    let timestamp: Date
    let username: String
    let profileImage: String?
    
    var timeAgo: String {
        let secondsAgo = Int(Date().timeIntervalSince(timestamp))
        
        if secondsAgo < 5 {
            return "just now"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
