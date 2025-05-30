//
//  FavoritesViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


/// View model responsible for managing and syncing the user's favorite plants with Firestore.
///
/// `FavoritesViewModel` handles real-time updates to the favorites list, adding/removing listeners,
/// and decoding `Plant` data from Firestore documents.
///
/// The class ensures UI stays updated through the `@Published` `favoritePlants` property.
class FavoritesViewModel: ObservableObject {
    
    /// List of favorite plants, automatically updated from Firestore.
    @Published var favoritePlants: [Plant] = []
    
    /// Holds individual plant listeners for cleanup.
    private var plantListeners: [ListenerRegistration] = []
    
    /// Firestore database reference.
    let db = Firestore.firestore()
    
    /// Listener for user document changes.
    private var userListener: ListenerRegistration?
    
    /// Removes all Firestore listeners to prevent memory leaks.
    func removeListeners() {
        plantListeners.forEach { $0.remove() }
        plantListeners.removeAll()
        
        userListener?.remove()
        userListener = nil
    }
    
    
    /// Removes a plant from the user's favorites in Firestore.
    /// - Parameter plantId: The ID of the plant to remove.
    func removeFavoritePlant(plantId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .updateData([
                "favoritePlants": FieldValue.arrayRemove([plantId])
            ]) { error in
                if let error = error {
                    print("Error removing favorite plant: \(error)")
                } else {
                    print("Successfully removed favorite plant")
                    DispatchQueue.main.async {
                        self.favoritePlants.removeAll { $0.id == plantId }
                    }
                }
            }
    }
    
    /// Starts listening to the current user's favorite plant list and fetches details.
    func fetchFavorites() {
        
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User must be logged in to add to cart.")
            return
        }
        
        // Remove existing user listener before adding a new one
        userListener?.remove()
        userListener = db.collection("users").document(userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to favorites: \(error)")
                    return
                }
                
                guard let data = snapshot?.data(),
                      let favoriteIDs = data["favoritePlants"] as? [String] else {
                    print("No favorites found for user.")
                    return
                }
                
                DispatchQueue.main.async {
                    self.fetchFavoritePlants(from: favoriteIDs)
                }
            }
        
    }
    
    /// Fetches plant documents based on a list of plant IDs.
    /// Listens to real-time updates for each plant.
    /// - Parameter ids: The list of plant document IDs to observe.
    func fetchFavoritePlants(from ids: [String]) {
        // Remove previous listeners
        plantListeners.forEach { $0.remove() }
        plantListeners.removeAll()
        favoritePlants = []
        
        for id in ids {
            let listener = db.collection("plantsDetails").document(id)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error listening to plant \(id): \(error)")
                        return
                    }
                    
                    guard let document = snapshot,
                          let plant = try? document.data(as: Plant.self) else {
                        print("Could not decode plant \(id)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // Replace if exists, otherwise append
                        if let index = self.favoritePlants.firstIndex(where: { $0.id == id }) {
                            self.favoritePlants[index] = plant
                        } else {
                            self.favoritePlants.append(plant)
                        }
                    }
                }
            
            plantListeners.append(listener)
        }
    }
    
}
