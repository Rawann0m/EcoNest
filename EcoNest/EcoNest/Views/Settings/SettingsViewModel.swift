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
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 0, userInfo: nil)))
            return
        }

        let imageID = UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference().child("UserProfile/\(imageID).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(error ?? NSError(domain: "URL error", code: 0, userInfo: nil)))
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
            uploadImage(image: newImage!) { result in
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
