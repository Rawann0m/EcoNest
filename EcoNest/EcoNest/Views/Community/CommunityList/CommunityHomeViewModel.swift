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
    
    init() {
        fetchCommunities()
    }
    
    func fetchCommunities() {
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
                        let name = data["name"] as! String
                        let description = data["description"] as! String
                        
                        print("Data: \(data)")
                        
                        self.communities.append(Community(id: document.documentID,name: name, description: description, members: members))
                        
                    }
                }
            }
        }
    }
}
