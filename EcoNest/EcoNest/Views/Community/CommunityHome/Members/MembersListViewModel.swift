//
//  MembersListViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

class MembersListViewModel: ObservableObject {
    @Published var members: [User] = []
    @Published var isLoading: Bool = false
    
    init(members: [String]){
        fetchMembers(members: members)
    }
    
    func fetchMembers(members: [String]) {
        isLoading = true
        print("Total members to fetch: \(members.count)")
        
        if members.isEmpty {
            isLoading = false
            return
        }
        
        for member in members {
            print("Fetching member ID: \(member)")
            
            FirebaseManager.shared.firestore.collection("users").document(member).getDocument { snapshot, error in
                if let error = error {
                    print("Error getting document: \(error)")
                } else if let snapshot = snapshot, snapshot.exists {
                    if let data = snapshot.data() {
                        let name = data["username"] as? String ?? "Unknown"
                        let email = data["email"] as? String ?? "Unknown"
                        let profileImage = data["profileImage"] as? String ?? ""
                        
                        let user = User(id: snapshot.documentID, username: name, email: email, profileImage: profileImage)
                        
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
