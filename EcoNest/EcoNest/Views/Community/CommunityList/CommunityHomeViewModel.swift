//
//  CommunityHomeViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import Firebase

class CommunityListViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var selectedCommunity: Community?
   // @Published var memberOfCommunity: Bool = false
    
    init() {
        fetchCommunities()
    }
    
    func fetchCommunities() {
        
        communities = []
        
        FirebaseManager.shared.firestore.collection("community").getDocuments { (snapshot, error) in
            
            if let error = error {
                
                print("Error getting documents: \(error)")
                
            } else if let documents = snapshot?.documents {
                
                print("Found \(documents.count) documents")
                
                for document in documents {
                    
                    print("Document ID: \(document.documentID)")
                    let data = document.data()

                    if data.isEmpty {
                        
                        print("data is empty")
                        
                    } else {
                        // get number of members
                        let members = data["members"] as! Array<String>
                        var isMember = false
                        
                        for member in members {
                            if member == FirebaseManager.shared.auth.currentUser?.uid {
                                isMember = true
                            }
                        }
                        
                        let name = data["name"] as! String
                        let description = data["description"] as! String
                        
                        print("Data: \(data)")
                        
                        self.communities.append(Community(id: document.documentID,name: name, description: description, members: members, memberOfCommunity: isMember))
                        
                    }
                }
            }
        }
    }
    
    func addUserIDToMembers(communityId: String, userId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .updateData([
                "members": FieldValue.arrayUnion([userId])
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Successfully added userID to member")
                }
            }
        fetchCommunities()
    }
    
    func removeUserIDToMembers(communityId: String, userId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .updateData([
                "members": FieldValue.arrayRemove([userId])
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Successfully removed userID from member")
                }
            }
    }
    
    func setMemberStatus(communityId: String, isMember: Bool) {
        if let index = communities.firstIndex(where: { $0.id == communityId }) {
            communities[index].memberOfCommunity = isMember
        }
    }
}
