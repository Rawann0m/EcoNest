//
//  SettingsViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 11/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

/// ViewModel responsible for managing user settings,
/// including fetching and updating user data such as
/// username, email, profile image, and preferences.
class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current logged-in user data model.
    @Published var user: User?
    
    /// Flag indicating if an upload operation is in progress.
    @Published var isUploading = false
    
    /// URL of the uploaded image (if any).
    @Published var uploadURL: URL?
    
    /// Stores the old username for comparison or reverting.
    @Published var oldName = ""
    
    /// The username input or displayed in the UI.
    @Published var name: String = ""
    
    /// The user's email.
    @Published var email: String = ""
    
    /// URL string of the user's profile image.
    @Published var profileImage: String = ""
    
    /// User preference to receive messages or notifications.
    @Published var receiveMessages: Bool = false
    
    /// Listener registration for Firestore snapshot listener to keep user data updated in realtime.
    var userListener: ListenerRegistration?
    
    /// Initializes the ViewModel and fetches the current user's data.
    init() {
        fetchCurrentUser()
    }
    
    /// Clean up listener when ViewModel is deallocated to prevent memory leaks.
    deinit {
        userListener?.remove()
    }
    
    // MARK: - Data Fetching
    
    /// Fetches the current logged-in user's data from Firestore and listens for real-time updates.
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("No authenticated user.")
            return
        }
        
        // Set up a real-time listener on the user's document
        userListener = FirebaseManager.shared.firestore.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found.")
                return
            }
            
            // Extract user info from Firestore document data
            self?.name = data["username"] as? String ?? ""
            self?.oldName = data["username"] as? String ?? ""
            self?.email = data["email"] as? String ?? ""
            self?.profileImage = data["profileImage"] as? String ?? ""
            self?.receiveMessages = data["receiveMessages"] as? Bool ?? false
            
            // Update user model for use in UI
            self?.user = User(
                username: self?.name ?? "",
                email: self?.email ?? "",
                profileImage: self?.profileImage ?? "",
                receiveMessages: self?.receiveMessages ?? false
            )
        }
    }
    
    // MARK: - Data Updating
    
    /// Updates user information in Firestore. Uploads a new profile image if provided.
    /// - Parameters:
    ///   - user: The user model with updated data.
    ///   - newImage: Optional new UIImage for profile picture.
    func updateUserInformation(user: User, newImage: UIImage?) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("No authenticated user.")
            return
        }
        
        // If no new image, update only the text data
        if newImage == nil {
            FirebaseManager.shared.firestore.collection("users").document(uid)
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
            // Upload new profile image first
            PhotoUploaderManager.shared.uploadUserImage(image: newImage!) { result in
                switch result {
                case .success(let url):
                    // After image upload success, update Firestore with new image URL
                    FirebaseManager.shared.firestore.collection("users").document(uid)
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
    
    /// Updates the user's preference for receiving messages in Firestore.
    func updateReceiveMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("No authenticated user.")
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid)
            .updateData([
                "receiveMessages": self.receiveMessages
            ]) { error in
                if let error = error {
                    print("Firestore update error: \(error.localizedDescription)")
                } else {
                    print("User updated receiving Messages")
                }
            }
    }
}
