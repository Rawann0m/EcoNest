//
//  Posts.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Hashable {
    @DocumentID var id: String?
    let userId: String
    let content: [String]
    let timestamp: Timestamp
    var likes: [String]
    
    var user: User?
    var postReplies: [Post] = []
    var numberOfReplies: Int = 0
    var likedByCurrentUser: Bool = false
}
