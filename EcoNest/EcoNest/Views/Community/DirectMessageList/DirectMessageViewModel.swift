//
//  DirectMessageViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 15/11/1446 AH.
//

import SwiftUI
import Firebase

class DirectMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var isUserLogOut: Bool = false
    @Published var recentMessages: [RecentMessage] = []
    
    
    var firestoreListener: ListenerRegistration?
    
    init(){
        DispatchQueue.main.async{
            self.isUserLogOut = FirebaseManager.shared.auth.currentUser == nil
        }
        
        fetchRecentMessage()
    }
    
    deinit{
        firestoreListener?.remove()
    }
    
    func fetchRecentMessage(){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        firestoreListener?.remove()
        
        firestoreListener = FirebaseManager.shared.firestore.collection("recentMessages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("failed to listen to recent messages: \(error)")
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    
                    // remove and replace recent message
                    if let index = self.recentMessages.firstIndex(where: { $0.id == docId }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    switch change.type {
                    case .added, .modified:
                        if let rm = try? change.document.data(as: RecentMessage.self) {
                            self.recentMessages.insert(rm, at: 0)
                        }
                    case .removed:
                        break
                    }
                }
            }
    }
    
    
    func DeleteMessage(index: IndexSet) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let index = index.first else{
            return
        }
        
        let toId = self.recentMessages[index].toId == uid ? self.recentMessages[index].fromId : self.recentMessages[index].toId
        print(toId)
        
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
                
                FirebaseManager.shared.firestore.collection("recentMessages").document(uid).collection("messages").document(toId).delete()
                
                print("all messages deleted")
                
                self.recentMessages.remove(at: index)
            }
    }
    
}
