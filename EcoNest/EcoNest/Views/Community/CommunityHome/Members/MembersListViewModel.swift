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
    
//    init(members: [String]) {
//        fetchMembers(members: members)
//    }
//    
    func fetchMembers(members: [String] ) {
        for member in members {
            FirebaseManager.shared.firestore.collection("users").document(member).getDocument { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    if let data = snapshot?.data() {
                        let name = data["username"] as! String
                        let email = data["email"] as! String
                        let profileImage = data["profileImage"] as! String
                        
                        let user = User(id: snapshot?.documentID, username: name, email: email, profileImage: profileImage)
                        
                        print("id : \(snapshot?.documentID ?? "no id")")
                        self.members.append(user)
                    }
                }
            }
        }
    }
}
