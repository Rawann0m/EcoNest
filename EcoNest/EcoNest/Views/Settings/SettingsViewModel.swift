//
//  SettingsViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 11/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isUploading = false
    @Published var uploadURL: URL?
    
    init(){
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        if let uid = FirebaseManager.shared.auth.currentUser?.uid {
            FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { (snapshot, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                } else if let document = snapshot {
                    let data = document.data()
                    if let data = data {
                        
                        let username = data["username"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let profileImage = data["profileImage"] as? String ?? ""
                        
                        self.user = User(username: username, email: email, profileImage: profileImage)
                    }
                }
            }
        }
    }
    
    func updateUserInformation(user: User, newImage: UIImage?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("No authenticated user.")
            return
        }
        
        if newImage == nil {
            FirebaseManager.shared.firestore.collection("users")
                .document(uid)
                .updateData([
                    "username": user.username,
                    "email": user.email,
                    "profileImage": user.profileImage
                ]) { error in
                    if let error = error {
                        print("Firestore update error (no image change): \(error.localizedDescription)")
                    } else {
                        print("User updated without changing image.")
                    }
                }
        } else {
            PhotoUploaderManager.shared.uploadUserImage(image: newImage!) { result in
                switch result {
                case .success(let url):
                    FirebaseManager.shared.firestore.collection("users")
                        .document(uid)
                        .updateData([
                            "username": user.username,
                            "email": user.email,
                            "profileImage": url.absoluteString
                        ]) { error in
                            if let error = error {
                                print("Firestore update error: \(error.localizedDescription)")
                            } else {
                                print("User updated with new image.")
                            }
                        }
                case .failure(let error):
                    print("Image upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

}
