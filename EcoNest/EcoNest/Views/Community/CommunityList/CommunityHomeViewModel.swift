//
//  CommunityHomeViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import Firebase

class CommunityViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var selectedCommunity: Community?
    @Published var isLoading: Bool = false
    @Published var selectedCommunityMembers: [String] = []
    
    var communityListener: ListenerRegistration?
    var selectedCommunityListener: ListenerRegistration?
    
    init() {
        fetchCommunities()
    }
    
    deinit {
        communityListener?.remove()
        selectedCommunityListener?.remove()
    }
    
    func fetchCommunities() {
        communities = []
        isLoading = true
        communityListener?.remove()
        
        communityListener = FirebaseManager.shared.firestore.collection("community").addSnapshotListener { [weak self] (snapshot, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                self.isLoading = false
            } else if let documents = snapshot?.documents {
                print("Found \(documents.count) documents")
                
                snapshot?.documentChanges.forEach { change in
                    let data = change.document.data()
                    guard !data.isEmpty else {
                        print("data is empty")
                        return
                    }
                    
                    let id = change.document.documentID
                    let name = data["name"] as? [String] ?? []
                    let description = data["description"] as? [String] ?? []
                    let members = data["members"] as? [String] ?? []
                    let currentUserId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
                    let isMember = members.contains(currentUserId)
                    let community = Community(id: id, name: name, description: description, members: members, memberOfCommunity: isMember)
                    
                    switch change.type {
                    case .added:
                        if !self.communities.contains(where: { $0.id == id }) {
                            self.communities.append(community)
                        }
                        
                    case .modified:
                        if let index = self.communities.firstIndex(where: { $0.id == id }) {
                            self.communities[index] = community
                        }
                        
                    case .removed:
                        self.communities.removeAll { $0.id == id }
                        
                    default:
                        break
                    }
                }
                
                self.isLoading = false
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
    }
    
    func removeUserIDFromMembers(communityId: String, userId: String) {
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
    
    
    func listenToSelectedCommunity(communityId: String) {
        selectedCommunityListener?.remove()
        
        selectedCommunityListener = FirebaseManager.shared.firestore
            .collection("community")
            .document(communityId)
            .addSnapshotListener { [weak self] (documentSnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to community: \(error)")
                    return
                }
                
                guard let data = documentSnapshot?.data(), let documentID = documentSnapshot?.documentID else {
                    print("No data found for community")
                    return
                }
                
                let name = data["name"] as? [String] ?? []
                let description = data["description"] as? [String] ?? []
                let members = data["members"] as? [String] ?? []
                let currentUserId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
                let isMember = members.contains(currentUserId)
                
                self.selectedCommunity = Community(
                    id: documentID,
                    name: name,
                    description: description,
                    members: members,
                    memberOfCommunity: isMember
                )
                self.selectedCommunityMembers = members
                print("hiiiii \(self.selectedCommunityMembers)")
            }
    }
    
}
