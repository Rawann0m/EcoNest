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
    @DocumentID var id: String?
    let content: [String]
    let toId: String
    let fromId: String
    let timestamp: Timestamp
    let username: String
    let profileImage: String?
    var lastSeenMessage: String?
    var unreadMessages: Int = 0
    
}
