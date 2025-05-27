//
//  ChatViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 15/11/1446 AH.
//

import SwiftUI
import Firebase

/// ViewModel responsible for managing chat messages between users.
/// Handles fetching, sending, and updating messages in Firestore,
/// as well as keeping recent messages and read status in sync.
class ChatViewModel: ObservableObject {
    
    /// The current text input in the chat input field.
    @Published var chatText = ""
    
    /// The list of chat messages between current user and chatUser.
    @Published var chatMessages: [Message] = []
    
    /// Optional selected picture string, can be used to store image message to show.
    @Published var selectedPic: String?
    
    /// The user that current user is chatting with.
    var chatUser: User?
    
    /// Firestore listener to keep chat messages updated in real-time.
    var firestoreListener: ListenerRegistration?
    
    /// Initializes the ChatViewModel with an optional chat user.
    /// - Parameter chatUser: The user to chat with.
    init(chatUser: User?) {
        self.chatUser = chatUser
        
        // Start listening for messages once chatUser is set.
        fetchMessages()
    }
    
    /// Fetches messages between the current user and chatUser from Firestore in real-time.
    /// Listens to changes and appends new messages as they arrive.
    func fetchMessages() {
        // Get current logged-in user ID.
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        // Get chat partner's user ID.
        guard let toId = chatUser?.id else { return }
        
        // Remove any existing listener to avoid duplicates.
        firestoreListener?.remove()
        
        // Clear current message list before fetching new ones.
        chatMessages.removeAll()
        
        // Setup Firestore real-time listener for messages ordered by timestamp.
        firestoreListener = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                // Process new message documents added.
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        let docId = change.document.documentID
                        let messageData = Message(documentId: docId, data: data)
                        self.chatMessages.append(messageData)
                    }
                }
            }
    }
    
    /// Handles sending a message to the chatUser.
    /// Saves the message in both sender's and receiver's Firestore collections.
    /// Updates recent message collections for both users.
    /// - Parameter content: An array of strings representing the content of the message (text, or could be multiple parts).
    func handleSendMessage(content: [String]) {
        print("text sent: \(chatText)")
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.id else { return }
        
        // Reference to sender's message collection document.
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        // Message data to be saved.
        let messageData: [String: Any] = [
            "fromId": fromId,
            "toId": toId,
            "content": content,
            "timestamp": Timestamp(),
            "isRead": false
        ]
        
        // Save message for sender.
        document.setData(messageData) { error in
            if let error = error {
                print("failed to send message: \(error.localizedDescription)")
                return
            }
        }
        
        // Update recent messages for sender and receiver.
        persistRecentMessage(content: content)
        
        // Reference to receiver's message collection document.
        let receiverDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()

        // Save message for receiver.
        receiverDocument.setData(messageData) { error in
            if let error = error {
                print("failed to send message: \(error.localizedDescription)")
                return
            }
        }
        
        // Clear input field after sending.
        chatText = ""
    }

    /// Saves or updates the recent message data for both the sender and receiver.
    /// This is used to show the latest message in a conversation list or summary.
    /// - Parameter content: The content of the message.
    private func persistRecentMessage(content: [String]) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toUser = chatUser else { return }
        
        let fromId = uid
        let toId = toUser.id ?? ""
        
        // Fetch current user's data to include username and profile image in recent message.
        FirebaseManager.shared.firestore.collection("users").document(fromId).getDocument { snapshot, error in
            guard let fromUserData = snapshot?.data(),
                  let fromUsername = fromUserData["username"] as? String,
                  let fromProfileImage = fromUserData["profileImage"] as? String
                else {
                print("Failed to fetch sender info")
                return
            }
            
            print("fromUserData: \(fromProfileImage)")
            print("toUserData: \(toUser.profileImage)")
            
            // Data for recent message from sender's perspective.
            let recentMessageData: [String: Any] = [
                "timestamp": Timestamp(),
                "content": content,
                "fromId": fromId,
                "toId": toId,
                "username": toUser.username,
                "profileImage": toUser.profileImage
            ]
            
            // Data for recent message from receiver's perspective.
            let receiverMessageData: [String: Any] = [
                "timestamp": Timestamp(),
                "content": content,
                "fromId": fromId,
                "toId": toId,
                "username": fromUsername,
                "profileImage": fromProfileImage
            ]
            
            // Save recent message for sender.
            let senderDoc = FirebaseManager.shared.firestore
                .collection("recentMessages")
                .document(fromId)
                .collection("messages")
                .document(toId)
            
            // Save recent message for receiver.
            let receiverDoc = FirebaseManager.shared.firestore
                .collection("recentMessages")
                .document(toId)
                .collection("messages")
                .document(fromId)
            
            senderDoc.setData(recentMessageData) { error in
                if let error = error {
                    print("Error saving sender recent message:", error)
                }
            }
            
            receiverDoc.setData(receiverMessageData) { error in
                if let error = error {
                    print("Error saving receiver recent message:", error)
                }
            }
        }
    }

    /// Marks all unread messages from the specified user as read.
    /// - Parameter toId: The ID of the user whose messages should be marked read.
    func markMessagesAsRead(toId: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }

        FirebaseManager.shared.firestore.collection("messages")
            .document(uid)
            .collection(toId)
            .whereField("fromId", isEqualTo: toId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching unread messages: \(error)")
                    return
                }

                // Update each unread message document to mark as read.
                snapshot?.documents.forEach { document in
                    document.reference.updateData(["isRead": true])
                }
            }
    }
    
    func markLastSeenMessage(toId: String, lastMessageId: String){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("recentMessages")
            .document(uid)
            .collection("messages")
            .document(toId)
            .updateData([
                "lastSeenMessage": lastMessageId
            ]) { error in
                if let error = error {
                    print("Error adding user to members: \(error)")
                } else {
                    print("Successfully added userID to members")
                }
            }
    }
    
}
