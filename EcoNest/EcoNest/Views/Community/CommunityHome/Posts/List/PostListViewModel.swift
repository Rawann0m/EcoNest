//
//  PostListViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 13/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

class PostsListViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var selectedPost: Post?
    @Published var isLoading: Bool = false
    @Published var postReplies: [Post] = []
    
    var firestoreListener: ListenerRegistration?
    var postRepliesListener: ListenerRegistration?
    var repliesListeners: ListenerRegistration?
    var selectedPostListener: ListenerRegistration?
    
    init(communityId: String) {
        getCommunityPosts(communityId: communityId)
        print("here")
    }
    
    deinit {
        firestoreListener?.remove()
        postRepliesListener?.remove()
        repliesListeners?.remove()
        selectedPostListener?.remove()
    }
    
    func getCommunityPosts(communityId: String) {
        posts = []
        isLoading = true
        firestoreListener?.remove()
        posts.removeAll()
        
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")
        
        
        firestoreListener = postsRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
                self.isLoading = false
            } else {
                print("Posts count: \(snapshot?.documents.count ?? 0)")
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.isLoading = false
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added || change.type == .modified{
                        let data = change.document.data()
                        let postId = change.document.documentID
                        let content = data["content"] as? [String] ?? []
                        let timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
                        let userId = data["userId"] as? String ?? ""
                        let likes = data["likes"] as? [String] ?? []
                        
                        self.listenToRepliesCount(communityId: communityId, postId: postId, docRef: postsRef.document(postId)) { numberOfReplies in
                            
                            print("number of replies: \(numberOfReplies)")
                            
                            let isLiked = likes.contains(FirebaseManager.shared.auth.currentUser?.uid ?? "")
                            
                            
                            self.getUser(userId: userId) { user in
                                guard let user = user else {
                                    print("out")
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    print(isLiked)
                                    let post = Post(id: postId, userId: userId, content: content, timestamp: timestamp, likes: likes, user: user,  numberOfReplies: numberOfReplies, likedByCurrentUser: isLiked)
                                    
                                    
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
                }
            }
        }
    }
    
    
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
    
    
    func uploadImages(images: [UIImage], completion: @escaping (Result<[URL], Error>) -> Void) {
        let group = DispatchGroup()
        var uploadedURLs: [URL] = []
        var uploadError: Error?
        
        for image in images {
            group.enter()
            uploadImages(image: image) { result in
                switch result {
                case .success(let url):
                    uploadedURLs.append(url)
                case .failure(let error):
                    uploadError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = uploadError {
                completion(.failure(error))
            } else {
                completion(.success(uploadedURLs))
            }
        }
    }
    
    func uploadImages(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 0, userInfo: nil)))
            return
        }
        
        let imageID = UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference().child("Posts/\(imageID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(error ?? NSError(domain: "URL error", code: 0, userInfo: nil)))
                }
            }
        }
    }
    
    func addReplyToPost(communityId: String, postId: String, replay: Post){
        let replayPost = ["content": replay.content, "timestamp": replay.timestamp, "userId": replay.userId, "likes": replay.likes] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .collection("replies")
            .document()
            .setData(replayPost) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("successfully saved replay post data")
            }
    }
    
    
    func getPostsReplies(communityId: String, postId: String) {
        
        postReplies = []
        isLoading = true
        postRepliesListener?.remove()
        
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .collection("replies")
        
        postRepliesListener = postsRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
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
            
            dispatchGroup.notify(queue: .main) {
                self.isLoading = false
            }
        }
    }
    
    func getUser(userId: String, completion: @escaping (User?) -> Void) {
        FirebaseManager.shared.firestore.collection("users").document(userId).getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = snapshot, let data = document.data() {
                let username = data["username"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImage = data["profileImage"] as? String ?? ""
                
                let user = User(username: username, email: email, profileImage: profileImage)
                print("found user")
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    func addUserIDToFavorite(communityId: String, userId: String,  postId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .updateData([
                "likes": FieldValue.arrayUnion([userId])
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Successfully added userID to fav")
                }
            }
    }
    
    func removeUserIDFromFavorite(communityId: String, userId: String, postId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .updateData([
                "likes": FieldValue.arrayRemove([userId])
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Successfully removed userID from fav")
                }
            }
    }
    
    func removePost(communityId: String, postId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .delete { error in
                if let error = error {
                    print("Error removing post: \(error)")
                } else {
                    print("Post removed successfully.")
                    if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                        self.posts.remove(at: index)
                    }
                }
            }
    }
    
    func removeReplay(communityId: String, postId: String, replayId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
            .collection("replies")
            .document(replayId)
            .delete { error in
                if let error = error {
                    print("Error removing replay: \(error)")
                } else {
                    print("replay removed successfully.")
                }
            }
    }
    
    func listenToSelectedPost(communityId: String ,postId: String) {
        selectedPostListener?.remove()
        
        let postsRef = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .collection("posts")
            .document(postId)
        
        selectedPostListener =  postsRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening to post: \(error)")
                return
            }
            
            guard let data = documentSnapshot?.data(), let documentID = documentSnapshot?.documentID else {
                print("No data found for post")
                return
            }
            
            self.listenToRepliesCount(communityId: communityId, postId: postId, docRef: postsRef) { numberOfReplies in
                
                print("number of replies: \(numberOfReplies)")
                
                let likes = data["likes"] as? [String] ?? []
                
                let isLiked = likes.contains(FirebaseManager.shared.auth.currentUser?.uid ?? "")
                
                self.selectedPost?.likedByCurrentUser = isLiked
                self.selectedPost?.likes = likes
                self.selectedPost?.numberOfReplies = numberOfReplies
                
            }
            
        }
    }
    
}
