//
//  CommunityHomeViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import Firebase

/// ViewModel class responsible for managing community-related data and interactions.
/// It handles fetching communities, updating membership, and listening to realtime updates
/// from Firestore's "community" collection.
class CommunityViewModel: ObservableObject {
    
    /// List of all communities fetched from Firestore.
    @Published var communities: [Community] = []
    
    /// The currently selected community, updated via listener.
    @Published var selectedCommunity: Community?
    
    /// Indicates if data is currently being loaded.
    @Published var isLoading: Bool = false
    
    /// List of member user IDs of the selected community.
    @Published var selectedCommunityMembers: [String] = []
    
    /// Listener registration for realtime updates of the communities collection.
    var communityListener: ListenerRegistration?
    
    /// Listener registration for realtime updates of the selected community document.
    var selectedCommunityListener: ListenerRegistration?
    
    /// Initializes the ViewModel and starts fetching communities immediately.
    init() {
        fetchCommunities()
    }
    
    /// Called when the ViewModel is deallocated to clean up listeners.
    deinit {
        communityListener?.remove()
        selectedCommunityListener?.remove()
    }
    
    /// Fetches the list of communities from Firestore in realtime.
    /// Updates the `communities` array as changes occur (added, modified, removed).
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
                    
                    // Retrieve community details safely
                    let name = data["name"] as? [String] ?? []
                    let description = data["description"] as? [String] ?? []
                    let members = data["members"] as? [String] ?? []
                    
                    let currentUserId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
                    let isMember = members.contains(currentUserId)
                    
                    // Create Community model instance
                    let community = Community(id: id, name: name, description: description, members: members, memberOfCommunity: isMember)
                    
                    // Handle document changes
                    switch change.type {
                    case .added:
                        // Append community if not already present
                        if !self.communities.contains(where: { $0.id == id }) {
                            self.communities.append(community)
                        }
                    case .modified:
                        // Update existing community data
                        if let index = self.communities.firstIndex(where: { $0.id == id }) {
                            self.communities[index] = community
                        }
                    case .removed:
                        // Remove community from list
                        self.communities.removeAll { $0.id == id }
                    default:
                        break
                    }
                }
                
                self.isLoading = false
            }
        }
    }
    
    /// Adds a user ID to the members array of a specific community.
    /// - Parameters:
    ///   - communityId: The Firestore document ID of the community.
    ///   - userId: The user ID to add to the members list.
    func addUserIDToMembers(communityId: String, userId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .updateData([
                "members": FieldValue.arrayUnion([userId])
            ]) { error in
                if let error = error {
                    print("Error adding user to members: \(error)")
                } else {
                    print("Successfully added userID to members")
                }
            }
    }
    
    /// Removes a user ID from the members array of a specific community.
    /// - Parameters:
    ///   - communityId: The Firestore document ID of the community.
    ///   - userId: The user ID to remove from the members list.
    func removeUserIDFromMembers(communityId: String, userId: String) {
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .updateData([
                "members": FieldValue.arrayRemove([userId])
            ]) { error in
                if let error = error {
                    print("Error removing user from members: \(error)")
                } else {
                    print("Successfully removed userID from members")
                }
            }
    }
    
    /// Listens to realtime updates of a specific community document.
    /// Updates the `selectedCommunity` and `selectedCommunityMembers` properties accordingly.
    /// - Parameter communityId: The Firestore document ID of the community to listen to.
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
                
                // Extract community data safely
                let name = data["name"] as? [String] ?? []
                let description = data["description"] as? [String] ?? []
                let members = data["members"] as? [String] ?? []
                
                let currentUserId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
                let isMember = members.contains(currentUserId)
                
                // Update published properties
                self.selectedCommunity = Community(
                    id: documentID,
                    name: name,
                    description: description,
                    members: members,
                    memberOfCommunity: isMember
                )
                self.selectedCommunityMembers = members
                
                print("Selected community members: \(self.selectedCommunityMembers)")
            }
    }
}
