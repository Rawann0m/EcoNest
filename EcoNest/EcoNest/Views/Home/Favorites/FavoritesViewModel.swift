//
//  FavoritesViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class FavoritesViewModel: ObservableObject {
    @Published var favoritePlants: [Plant] = []
    private var plantListeners: [ListenerRegistration] = []
    
    let db = Firestore.firestore()
    
    private var userListener: ListenerRegistration?

    func removeListeners() {
        plantListeners.forEach { $0.remove() }
        plantListeners.removeAll()
        
        userListener?.remove()
        userListener = nil
    }

    
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
    
    
    func fetchFavorites() {
        
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User must be logged in to add to cart.")
            return
        }
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
