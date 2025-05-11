//
//  PostsViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

class PostsViewModel: ObservableObject {
    @Published var posts: [Posts] = []
    
    func getCommunityPosts(communityId: String) {
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")

        postsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
            } else {
                print("Posts count: \(snapshot?.documents.count ?? 0)")
                for document in snapshot!.documents {
                    
                    let data = document.data()
                    let postId = document.documentID
                    let content = data["content"] as! [String]
                    let timestamp = data["createdAt"] as! Timestamp
                    let userId = data["userId"] as! String
                    
                    self.posts.append(Posts(id: postId, userId: userId, content: content, timestamp: timestamp))
                }
            }
        }
    }
}
