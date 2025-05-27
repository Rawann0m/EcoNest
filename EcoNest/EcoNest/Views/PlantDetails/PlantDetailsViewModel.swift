`//
//  PlantDetailsViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 20/05/2025.
//

import FirebaseFirestore
import SwiftUI

/// Manages and provides data for the plant detail screen, including plant info, product recommendations,
/// water/light levels, and favorite state.
///
/// `PlantDetailsViewModel` fetches data from Firestore based on a plant's name or ID, and supports
/// favoriting/unfavoriting logic with real-time status checking.
class PlantDetailsViewModel: ObservableObject {
    
    /// Current plant details retrieved from Firestore.
    @Published var plant : Plant?
    
    /// Products associated with the selected plant.
    @Published var products: [Product] = []
    
    /// Water usage level of the plant.
    @Published var waterLevel: Double?
    
    /// Light exposure level of the plant.
    @Published var lightLevel: Double?
    
    /// Indicates whether the plant is in the user's favorites.
    @Published var isFavorite: Bool = false
    
    /// Firestore instance.
    private var db = Firestore.firestore()
    
    /// Initializes the view model and begins fetching the plant by name.
    /// - Parameter PlantName: Name used to query the `plantsDetails` collection.
    init(PlantName: String) {
        getPlants(named: PlantName)
    }
    
    /// Toggles the plant’s favorite status in the UI and database.
    /// - Parameters:
    ///   - userId: The user's ID.
    ///   - plantId: The ID of the plant to favorite/unfavorite.
    func toggleFavorite(userId: String, plantId: String) {
        isFavorite.toggle()
        if isFavorite {
            addFavoritePlant(userId: userId, plantId: plantId)
        } else {
            removeFavoritePlant(userId: userId, plantId: plantId)
        }
    }
    
    /// Checks if a plant is already in the user's favorites.
    /// - Parameters:
    ///   - userId: The user’s ID.
    ///   - plantId: The plant’s ID.
    func checkFavoriteStatus(userId: String, plantId: String) {
        FirebaseManager.shared.firestore.collection("users")
            .document(userId)
            .getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    if let favorites = data?["favoritePlants"] as? [String] {
                        DispatchQueue.main.async {
                            self.isFavorite = favorites.contains(plantId)
                        }
                    }
                }
            }
    }
    
    /// Adds a plant to the user's favorites in Firestore.
    func addFavoritePlant(userId: String, plantId: String) {
        FirebaseManager.shared.firestore.collection("users")
            .document(userId)
            .updateData([
                "favoritePlants": FieldValue.arrayUnion([plantId])
            ]) { error in
                if let error = error {
                    print("Error adding favorite plant: \(error)")
                } else {
                    print("Successfully added favorite plant")
                }
            }
    }
    
    /// Removes a plant from the user's favorites in Firestore.
    func removeFavoritePlant(userId: String, plantId: String) {
        FirebaseManager.shared.firestore.collection("users")
            .document(userId)
            .updateData([
                "favoritePlants": FieldValue.arrayRemove([plantId])
            ]) { error in
                if let error = error {
                    print("Error removing favorite plant: \(error)")
                } else {
                    print("Successfully removed favorite plant")
                }
            }
    }
    
    /// Retrieves the water level for a plant.
    /// - Parameter plantId: The plant document ID.
    func getWaterLevel(for plantId: String) {
        db.collection("plantsDetails")
            .document(plantId).getDocument { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else if let document = snapshot {
                    let data = document.data()
                    if let data = data {
                        self.waterLevel = data["water"] as? Double ?? 0
                        
                    }
                }
            }
    }
    
    /// Retrieves the light level for a plant.
    /// - Parameter plantId: The plant document ID.
    func getLightLevel(for plantId: String) {
        db.collection("plantsDetails").document(plantId).getDocument { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let document = snapshot {
                let data = document.data()
                if let data = data {
                    self.lightLevel = data["light"] as? Double
                    
                }
            }
        }
    }
    
    /// Asynchronously fetches recommended products related to the plant.
    /// - Parameter plantId: The plant's ID used to filter products.
    @MainActor
    func fetchProducts(for plantId: String) async {
        
        do {
            let snap = try await db.collection("product")
                .whereField("plantId", isEqualTo: plantId)
                .getDocuments()
            
            products = try snap.documents.compactMap {
                try $0.data(as: Product.self)
            }
            
        } catch {
            products = []
        }
    }
    
    /// Fetches a plant by its name and populates associated data (products, water, light).
    /// - Parameter PlantName: The name of the plant to query.
    func getPlants(named PlantName: String) {
        db.collection("plantsDetails")
            .whereField( "name", isEqualTo: PlantName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching plant: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("❗️No plant found with name: \(PlantName)")
                    return
                }
                
                do {
                    let fetchedPlant = try document.data(as: Plant.self)
                    DispatchQueue.main.async { self.plant = fetchedPlant }
                    
                    // ⬇︎ Debug
                    if let id = fetchedPlant.id {
                        
                        Task { await self.fetchProducts(for: id) }
                        Task { self.getWaterLevel(for: id) }
                        Task { self.getLightLevel(for: id) }
                    } else {
                    }
                    
                    
                } catch {
                    print("❌ Decoding error:", error)
                }
            }
    }
}
`
