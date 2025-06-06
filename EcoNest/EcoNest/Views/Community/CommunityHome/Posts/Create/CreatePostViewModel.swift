//
//  CreatePostViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 13/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

/// ViewModel responsible for handling the creation and uploading of posts
/// to a specific community in Firestore.
class CreatePostViewModel: ObservableObject {
    
    /// Adds a new post to the Firestore database under the specified community.
    ///
    /// - Parameters:
    ///   - communityId: The ID of the community where the post will be added.
    ///   - post: The `Post` model containing the content, timestamp, userId, and likes.
    func addPost(communityId: String, post: Post) {
        // Prepare a dictionary representation of the post data to save
        let createdPost: [String: Any] = [
            "content": post.content,
            "timestamp": post.timestamp,
            "userId": post.userId,
            "likes": post.likes
        ]
        
        // Reference to the posts collection under the specified community document
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document() // Auto-generate a document ID
            .setData(createdPost) { error in
                if let error = error {
                    // Handle any errors during saving
                    print("Error saving post data: \(error.localizedDescription)")
                    return
                }
                // Success confirmation
                print("Successfully saved post data")
            }
    }
    
    func checkUserIsAMember(communityId: String, completion: @escaping (Bool) -> Void) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("No authenticated user.")
            completion(false)
            return
        }
        
        FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .getDocument { snapshot, error in
                
                if let error = error {
                    print("Error getting document: \(error)")
                    completion(false)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No community data found.")
                    completion(false)
                    return
                }
                
                let members = data["members"] as? [String] ?? []
                let isMember = members.contains(uid)
                completion(isMember)
            }
    }
}
