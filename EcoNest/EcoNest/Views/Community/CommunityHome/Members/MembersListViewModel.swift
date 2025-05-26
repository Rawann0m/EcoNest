//
//  MembersListViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

/// ViewModel responsible for fetching and managing a list of user members.
/// It handles fetching user data from Firestore and updating the UI accordingly.
class MembersListViewModel: ObservableObject {
    
    /// List of fetched members (users).
    @Published var members: [User] = []
    
    /// Indicates whether the ViewModel is currently loading data.
    @Published var isLoading: Bool = false
    
    /// The currently selected member from the list.
    @Published var selectedMember: User?
    
    /// Search text to filter the list of members (not yet implemented in this code).
    @Published var searchText: String = ""
    
    /// Initializer that starts fetching members given a list of member IDs.
    /// - Parameter members: An array of user IDs (String) to fetch from Firestore.
    init(members: [String]){
        fetchMembers(members: members)
    }
    
    /// Fetches user details for each member ID from Firestore and updates the members list.
    /// - Parameter members: Array of user IDs to fetch.
    func fetchMembers(members: [String]) {
        isLoading = true
        print("Total members to fetch: \(members.count)")
        
        // Early return if the list is empty
        if members.isEmpty {
            isLoading = false
            return
        }
        
        // Iterate over each member ID to fetch user details
        for member in members {
            print("Fetching member ID: \(member)")
            
            FirebaseManager.shared.firestore.collection("users").document(member).getDocument { snapshot, error in
                if let error = error {
                    // Log any errors during fetching
                    print("Error getting document: \(error)")
                } else if let snapshot = snapshot, snapshot.exists {
                    // Parse the document data into a User model
                    if let data = snapshot.data() {
                        let name = data["username"] as? String ?? "Unknown"
                        let email = data["email"] as? String ?? "Unknown"
                        let profileImage = data["profileImage"] as? String ?? ""
                        let receiveMessages = data["receiveMessages"] as? Bool ?? false
                        
                        let user = User(
                            id: snapshot.documentID,
                            username: name,
                            email: email,
                            profileImage: profileImage,
                            receiveMessages: receiveMessages
                        )
                        
                        // Update the published members array on the main thread
                        DispatchQueue.main.async {
                            self.members.append(user)
                            self.isLoading = false
                        }
                    } else {
                        print("No data in snapshot for member: \(member)")
                        self.isLoading = false
                    }
                } else {
                    print("Document does not exist for member: \(member)")
                    self.isLoading = false
                }
            }
        }
    }

}
