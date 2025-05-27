//
//  DirectMessageViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 15/11/1446 AH.
//

import SwiftUI
import Firebase

/// ViewModel responsible for handling direct messaging functionalities.
/// Manages fetching, updating, and deleting recent direct messages,
/// tracks unread message counts, and monitors user logout state.
class DirectMessageViewModel: ObservableObject {
    
    /// Error message to display if any Firebase operations fail
    @Published var errorMessage = ""
    
    /// Flag to indicate if the current user is logged out
    @Published var isUserLogOut: Bool = false
    
    /// List of recent messages involving the current user
    @Published var recentMessages: [RecentMessage] = []
    
    /// Listener for real-time updates from Firestore recent messages collection
    var firestoreListener: ListenerRegistration?
    
    /// Initializes the ViewModel, sets the user logout status,
    /// and fetches recent messages.
    init(){
        fetchRecentMessage()
    }
    
    /// Cleans up Firestore listener when the ViewModel is deallocated
    deinit {
        firestoreListener?.remove()
    }
    
    /// Fetches recent messages for the logged-in user from Firestore.
    /// Listens for real-time updates and updates the recentMessages array accordingly.
    func fetchRecentMessage() {
        // Ensure user is logged in
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        // Remove previous listener if any
        firestoreListener?.remove()
        
        // Listen to changes in recentMessages collection for the user,
        // ordered by timestamp for chronological updates
        firestoreListener = FirebaseManager.shared.firestore.collection("recentMessages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("Failed to listen to recent messages: \(error)")
                    return
                }
                
                // Process document changes (added, modified, removed)
                snapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    let data = change.document.data()
                    
                    // Parse message data safely
                    let content = data["content"] as? [String] ?? []
                    let toId = data["toId"] as? String ?? ""
                    let fromId = data["fromId"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                    let username = data["username"] as? String ?? ""
                    let profileImage = data["profileImage"] as? String ?? ""
                    
                    // Determine the other party's ID for the conversation
                    var getId = toId
                    if toId == uid {
                        getId = fromId
                    }
                    
                    // Fetch the count of unread messages from this other party
                    self.getUnreadCount(toId: getId) { unreadCount in
                        // Remove existing message with the same docId if exists to avoid duplicates
                        if let index = self.recentMessages.firstIndex(where: { $0.id == docId }) {
                            self.recentMessages.remove(at: index)
                        }
                        
                        print("Unread messages count: \(unreadCount)")
                        
                        switch change.type {
                        case .added, .modified:
                            // Create and insert the updated RecentMessage at the front of the list
                            let recentMessage = RecentMessage(
                                id: docId,
                                content: content,
                                toId: toId,
                                fromId: fromId,
                                timestamp: timestamp,
                                username: username,
                                profileImage: profileImage,
                                unreadMessages: unreadCount
                            )
                            self.recentMessages.insert(recentMessage, at: 0)
                            
                        case .removed:
                            // Handle removal if necessary (currently no action)
                            break
                        }
                    }
                }
            }
    }
    
    /// Deletes all messages between the current user and the selected conversation partner
    /// and removes the conversation from recent messages list.
    /// - Parameter index: The index set of the conversation to delete.
    func DeleteMessage(index: IndexSet) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let index = index.first else {
            return
        }
        
        // Determine the ID of the conversation partner
        let toId = self.recentMessages[index].toId == uid ? self.recentMessages[index].fromId : self.recentMessages[index].toId
        print("Deleting messages with user: \(toId)")
        
        // Fetch and delete all message documents in the conversation sub-collection
        FirebaseManager.shared.firestore.collection("messages")
            .document(uid)
            .collection(toId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No message items found.")
                    return
                }
                
                for doc in documents {
                    doc.reference.delete()
                }
                
                // Remove the conversation from recentMessages collection
                FirebaseManager.shared.firestore.collection("recentMessages")
                    .document(uid)
                    .collection("messages")
                    .document(toId)
                    .delete()
                
                print("All messages deleted with user: \(toId)")
                
                // Remove from local array
                self.recentMessages.remove(at: index)
            }
    }
    
    /// Retrieves the number of unread messages from a particular user.
    /// - Parameters:
    ///   - toId: The ID of the conversation partner.
    ///   - completion: Closure returning the count of unread messages.
    func getUnreadCount(toId: String, completion: @escaping (Int) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            completion(0)
            return
        }
        
        FirebaseManager.shared.firestore.collection("messages")
            .document(uid)
            .collection(toId)
            .whereField("fromId", isEqualTo: toId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch unread messages: \(error)")
                    completion(0)
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                completion(count)
            }
    }
}
