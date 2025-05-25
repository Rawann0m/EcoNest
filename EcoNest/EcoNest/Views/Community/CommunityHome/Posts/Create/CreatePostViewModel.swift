//
//  CreatePostViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 13/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

class CreatePostViewModel: ObservableObject {
    
    func addPost(communityId: String, post: Post){
        let createdPost = ["content": post.content, "timestamp": post.timestamp, "userId": post.userId, "likes": post.likes] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document()
            .setData(createdPost) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("successfully saved post data")
            }
    }
}
