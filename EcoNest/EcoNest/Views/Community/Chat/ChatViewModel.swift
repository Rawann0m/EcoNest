//
//  ChatViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 15/11/1446 AH.
//


import SwiftUI
import Firebase

class ChatViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var chatMessages: [Message] = []
    @Published var selectedPic: String?
    
    var chatUser: User?
    
    init(chatUser: User?){
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.id else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
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
    
    
    func handleSendMessage(content: [String]){
        print("text sent: \(chatText)")
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.id else { return }
        
        let doecument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData: [String: Any] = [
            "fromId": fromId,
            "toId": toId,
            "content": content,
            "timestamp": Timestamp(),
        ]
        
        doecument.setData(messageData) { error in
            if let error = error {
                print("failed to send message: \(error.localizedDescription)")
                return
            }
        }
        
        persistRecentMessage(content: content)
        
        let reciverDoecument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()

        reciverDoecument.setData(messageData) { error in
            if let error = error {
                print("failed to send message: \(error.localizedDescription)")
                return
            }
        }
        
        
        chatText = ""
    }

    private func persistRecentMessage(content: [String]) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toUser = chatUser else { return }
        
        let fromId = uid
        let toId = toUser.id ?? ""
        
        // Get current user info
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
            
            let recentMessageData: [String: Any] = [
                "timestamp": Timestamp(),
                "content": content,
                "fromId": fromId,
                "toId": toId,
                "username": toUser.username,
                "profileImage": toUser.profileImage
            ]
            
            let receiverMessageData: [String: Any] = [
                "timestamp": Timestamp(),
                "content": content,
                "fromId": fromId,
                "toId": toId,
                "username": fromUsername,
                "profileImage": fromProfileImage
            ]
            
            // Save to current user recentMessages
            let senderDoc = FirebaseManager.shared.firestore
                .collection("recentMessages")
                .document(fromId)
                .collection("messages")
                .document(toId)
            
            // Save to receiver recentMessages
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

    
}
