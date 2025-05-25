//
//  PostListViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 13/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

/// ViewModel class responsible for managing posts and their replies within a community.
/// It handles fetching, listening to real-time updates, adding replies, and user-related data retrieval.
/// Implements ObservableObject to enable SwiftUI views to reactively update.
class PostsListViewModel: ObservableObject {
    
    /// List of posts fetched from Firestore.
    @Published var posts: [Post] = []
    
    /// The currently selected post.
    @Published var selectedPost: Post?
    
    /// The currently selected pic.
    @Published var selectedPic: String?
    
    
    @Published var showPic: Bool = false
    
    /// Flag indicating whether data is being loaded.
    @Published var isLoading: Bool = false
    
    /// List of replies for a selected post.
    @Published var postReplies: [Post] = []
    
    /// Flag to notify if the selected post was deleted.
    @Published var didDeleteSelectedPost = false
    
    /// Text used to filter posts (e.g., search functionality).
    @Published var searchText: String = ""
    
    // Firestore listeners for real-time updates.
    var firestoreListener: ListenerRegistration?
    var postRepliesListener: ListenerRegistration?
    var repliesListeners: ListenerRegistration?
    var selectedPostListener: ListenerRegistration?
    
    /// Initializes the ViewModel and starts fetching posts for the specified community.
    /// - Parameter communityId: The identifier of the community to fetch posts from.
    init(communityId: String) {
        getCommunityPosts(communityId: communityId)
        print("ViewModel initialized and started fetching posts.")
    }
    
    /// Clean up Firestore listeners when ViewModel is deinitialized to avoid memory leaks.
    deinit {
        firestoreListener?.remove()
        postRepliesListener?.remove()
        repliesListeners?.remove()
        selectedPostListener?.remove()
    }
    
    /// Fetches and listens to posts in a community collection in Firestore.
    /// Updates the `posts` array reactively when new posts are added or modified.
    /// - Parameter communityId: The identifier of the community to listen for posts.
    func getCommunityPosts(communityId: String) {
        posts = []
        isLoading = true
        
        // Remove previous listener if any.
        firestoreListener?.remove()
        posts.removeAll()
        
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")
        
        // Real-time snapshot listener for posts.
        firestoreListener = postsRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
                self.isLoading = false
                return
            }
            
            print("Posts count: \(snapshot?.documents.count ?? 0)")
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                self.isLoading = false
                return
            }
            
            // Process document changes (added, modified, removed)
            snapshot?.documentChanges.forEach { change in
                if change.type == .added || change.type == .modified {
                    let data = change.document.data()
                    let postId = change.document.documentID
                    let content = data["content"] as? [String] ?? []
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
                    let userId = data["userId"] as? String ?? ""
                    let likes = data["likes"] as? [String] ?? []
                    
                    // Listen to the count of replies for each post
                    self.listenToRepliesCount(communityId: communityId, postId: postId, docRef: postsRef.document(postId)) { numberOfReplies in
                        
                        print("number of replies: \(numberOfReplies)")
                        
                        // Check if the current user liked the post
                        let isLiked = likes.contains(FirebaseManager.shared.auth.currentUser?.uid ?? "")
                        
                        // Fetch user data for the post author
                        self.getUser(userId: userId) { user in
                            guard let user = user else {
                                print("User data not found for userId: \(userId)")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                print("Post liked by current user: \(isLiked)")
                                
                                // Create Post object
                                let post = Post(id: postId, userId: userId, content: content, timestamp: timestamp, likes: likes, user: user, numberOfReplies: numberOfReplies, likedByCurrentUser: isLiked)
                                
                                // Update or add the post in the posts array
                                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                                    self.posts[index] = post
                                } else {
                                    self.posts.append(post)
                                }
                            }
                            self.isLoading = false
                        }
                    }
                }
                
                // Handle post removal
                if change.type == .removed {
                    self.posts.removeAll { $0.id == change.document.documentID }
                }
            }
        }
    }
    
    /// Listens to the count of replies for a specific post in real-time.
    /// - Parameters:
    ///   - communityId: The community ID.
    ///   - postId: The post ID.
    ///   - docRef: The document reference for the post.
    ///   - completion: Completion handler returning the number of replies.
    func listenToRepliesCount(communityId: String, postId: String, docRef: DocumentReference, completion: @escaping (Int) -> Void) {
        let subcollectionRef = docRef.collection("replies")
        
        repliesListeners = subcollectionRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to replies: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            let count = snapshot?.documents.count ?? 0
            completion(count)
        }
    }
    
    /// Adds a reply post to a specific post within a community.
    /// - Parameters:
    ///   - communityId: The community ID.
    ///   - postId: The post ID to which the reply will be added.
    ///   - replay: The reply post to add.
    func addReplyToPost(communityId: String, postId: String, replay: Post){
        let replayPost = [
            "content": replay.content,
            "timestamp": replay.timestamp,
            "userId": replay.userId,
            "likes": replay.likes
        ] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .collection("replies")
            .document()
            .setData(replayPost) { error in
                if let error = error {
                    print("Error adding reply: \(error)")
                    return
                }
                print("Successfully saved reply post data")
            }
    }
    
    /// Fetches replies for a given post and listens for real-time updates.
    /// Updates the `postReplies` array accordingly.
    /// - Parameters:
    ///   - communityId: The community ID.
    ///   - postId: The post ID to fetch replies for.
    func getPostsReplies(communityId: String, postId: String) {
        postReplies = []
        isLoading = true
        
        // Remove previous listener if any
        postRepliesListener?.remove()
        
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .collection("replies")
        
        // Real-time listener for replies
        postRepliesListener = postsRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting replies: \(error)")
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                self.postReplies = []
                self.isLoading = false
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            snapshot?.documentChanges.forEach { change in
                let replyData = change.document.data()
                let content = replyData["content"] as? [String] ?? []
                let timestamp = replyData["timestamp"] as? Timestamp ?? Timestamp()
                let likes = replyData["likes"] as? [String] ?? []
                let userId = replyData["userId"] as? String ?? ""
                
                let isLiked = likes.contains(FirebaseManager.shared.auth.currentUser?.uid ?? "")
                
                dispatchGroup.enter()
                
                // Fetch user data for reply author
                self.getUser(userId: userId) { user in
                    if let user = user {
                        let replyPost = Post(
                            id: change.document.documentID,
                            userId: userId,
                            content: content,
                            timestamp: timestamp,
                            likes: likes,
                            user: user,
                            likedByCurrentUser: isLiked
                        )
                        
                        switch change.type {
                        case .added:
                            if !self.postReplies.contains(where: { $0.id == replyPost.id }) {
                                self.postReplies.append(replyPost)
                            }
                        case .modified:
                            if let index = self.postReplies.firstIndex(where: { $0.id == replyPost.id }) {
                                self.postReplies[index] = replyPost
                            }
                        case .removed:
                            self.postReplies.removeAll { $0.id == replyPost.id }
                        default:
                            break
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Notify when all user fetches are done to update loading state
            dispatchGroup.notify(queue: .main) {
                self.isLoading = false
            }
        }
    }
    
    /// Fetches user information from Firestore for a given userId.
    /// - Parameters:
    ///   - userId: The ID of the user to fetch.
    ///   - completion: Completion handler returning the User object or nil if not found.
    func getUser(userId: String, completion: @escaping (User?) -> Void) {
        FirebaseManager.shared.firestore.collection("users").document(userId).getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting user document: \(error)")
                completion(nil)
                return
            }
            
            if let document = snapshot, let data = document.data() {
                let username = data["username"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImage = data["profileImage"] as? String ?? ""
                let receiveMessages = data["receiveMessages"] as? Bool ?? false
                
                let user = User(username: username, email: email, profileImage: profileImage, receiveMessages: receiveMessages)
                print("Found user: \(username)")
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Adds the given userId to the "likes" array of a post or a reply within a community.
    /// - Parameters:
    ///   - communityId: The ID of the community where the post is located.
    ///   - userId: The user ID to add to the favorites.
    ///   - postId: The ID of the post to update.
    ///   - replayId: Optional ID of the reply if the like is for a reply.
    ///   - isReply: Flag indicating whether the target is a reply (true) or a post (false).
    func addUserIDToFavorite(communityId: String, userId: String, postId: String, replayId: String? = nil, isReply: Bool = false) {
        
        // Reference to the post document in Firestore
        let documentRef = FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
        
        var ref = documentRef
        
        // If the like is for a reply, adjust the reference to the reply document
        if isReply {
            if let replayId = replayId {
                ref = ref.collection("replies").document(replayId)
            }
        }
        
        // Add the userId to the "likes" array using Firestore's atomic arrayUnion
        ref.updateData([
            "likes": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("Error adding userID to favorites: \(error)")
            } else {
                print("Successfully added userID to favorites")
            }
        }
    }
    
    /// Removes the given userId from the "likes" array of a post or a reply within a community.
    /// - Parameters:
    ///   - communityId: The ID of the community where the post is located.
    ///   - userId: The user ID to remove from the favorites.
    ///   - postId: The ID of the post to update.
    ///   - replayId: Optional ID of the reply if the removal is for a reply.
    ///   - isReply: Flag indicating whether the target is a reply (true) or a post (false).
    func removeUserIDFromFavorite(communityId: String, userId: String, postId: String, replayId: String? = nil, isReply: Bool = false) {
        
        // Reference to the post document in Firestore
        let documentRef = FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
        
        var ref = documentRef
        
        // If the removal is for a reply, adjust the reference to the reply document
        if isReply {
            if let replayId = replayId {
                ref = ref.collection("replies").document(replayId)
            }
        }
        
        // Remove the userId from the "likes" array using Firestore's atomic arrayRemove
        ref.updateData([
            "likes": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("Error removing userID from favorites: \(error)")
            } else {
                print("Successfully removed userID from favorites")
            }
        }
    }
    
    /// Deletes a post from a community.
    /// - Parameters:
    ///   - communityId: The ID of the community where the post is located.
    ///   - postId: The ID of the post to delete.
    func removePost(communityId: String, post: Post) {
        guard let postId = post.id else { return }
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .delete { error in
                if let error = error {
                    print("Error removing post: \(error)")
                } else {
                    print("Post removed successfully.")
                    // Indicate post deletion
                    self.didDeleteSelectedPost = true
                    // Remove the post from the local array to update UI
                    if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                        self.posts.remove(at: index)
                    }
                    
                    for image in post.content.filter({$0.lowercased().hasPrefix("http") }) {
                        PhotoUploaderManager.shared.DeleteImage(text: image, start: "/o/", end: "?")
                    }
                }
            }
        
//        deleteRepliesForPost(postId: postId) { error in
//            if let error = error {
//                print("Error deleting replies: \(error.localizedDescription)")
//            } else {
//                print("Replies deleted successfully.")
//            }
//        }
    }
    
    /// Deletes a reply to a post from a community.
    /// - Parameters:
    ///   - communityId: The ID of the community where the post is located.
    ///   - postId: The ID of the post to which the reply belongs.
    ///   - replayId: The ID of the reply to delete.
    func removeReplay(communityId: String, postId: String, replay: Post) {
        guard let replayId = replay.id else { return }
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .collection("replies")
            .document(replayId)
            .delete { error in
                if let error = error {
                    print("Error removing reply: \(error)")
                } else {
                    print("Reply removed successfully.")
                    for image in replay.content.filter({$0.lowercased().hasPrefix("http") }) {
                        PhotoUploaderManager.shared.DeleteImage(text: image, start: "/o/", end: "?")
                    }
                }
            }
    }
    
    /// Listens for real-time updates to a specific post and updates its likes and reply count accordingly.
    /// - Parameters:
    ///   - communityId: The ID of the community where the post is located.
    ///   - postId: The ID of the post to listen to.
    func listenToSelectedPost(communityId: String ,postId: String) {
        // Remove any previous listener to avoid duplicate callbacks
        selectedPostListener?.remove()
        
        // Reference to the specific post document in Firestore
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
        
        // Attach a snapshot listener for real-time updates on the post document
        selectedPostListener = postsRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening to post: \(error)")
                return
            }
            
            // Make sure the document exists and has data
            guard let data = documentSnapshot?.data(), let documentID = documentSnapshot?.documentID else {
                print("No data found for post")
                return
            }
            
            // Listen to the count of replies for this post
            self.listenToRepliesCount(communityId: communityId, postId: postId, docRef: postsRef) { numberOfReplies in
                
                print("number of replies: \(numberOfReplies)")
                
                let likes = data["likes"] as? [String] ?? []
                
                // Check if the current user liked this post
                let isLiked = likes.contains(FirebaseManager.shared.auth.currentUser?.uid ?? "")
                
                // Update the selected post's like status and reply count
                self.selectedPost?.likedByCurrentUser = isLiked
                self.selectedPost?.likes = likes
                self.selectedPost?.numberOfReplies = numberOfReplies
            }
        }
    }

    func deleteRepliesForPost(postId: String, batchSize: Int = 20, completion: @escaping (Error?) -> Void) {

        let repliesRef = FirebaseManager.shared.firestore.collection("post").document(postId).collection("replies")
        
        // Fetch a batch of replies
        repliesRef.limit(to: batchSize).getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                // No more replies to delete
                completion(nil)
                return
            }

            let batch = FirebaseManager.shared.firestore.batch()
            for doc in documents {
                batch.deleteDocument(doc.reference)
            }

            // Commit the batch
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(batchError)
                    return
                }

                // Recursively delete the next batch
                self.deleteRepliesForPost(postId: postId, batchSize: batchSize, completion: completion)
            }
        }
    }

}
