//
//  FirebaseManager.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    
    let auth = Auth.auth()  // Auth instance to manage authentication
    let storage = Storage.storage()  // Storage instance for handling file storage
    let firestore = Firestore.firestore()  // Firestore instance for database
    
    // Singleton pattern to create a shared instance of FirebaseManager
    static let shared = FirebaseManager()
    
    private init() {}
    
    var isLoggedIn: Bool {
        return auth.currentUser != nil
    }
    
    func getCurrentUser() -> DocumentReference? {
        guard let userId = auth.currentUser?.uid else {
            print("User not logged in")
            return nil
        }
        return firestore.collection("users").document(userId)
    }


}
