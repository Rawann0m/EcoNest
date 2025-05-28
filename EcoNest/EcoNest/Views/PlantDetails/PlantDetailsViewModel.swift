//
//  PlantDetailsViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 20/05/2025.
//

import FirebaseFirestore
import SwiftUI

class PlantDetailsViewModel: ObservableObject {
    @Published var plant : Plant?
    @Published var products: [Product] = []
    @Published var waterLevel: Double?
    @Published var lightLevel: Double?
    @Published var isFavorite: Bool = false
    
    
    private var db = Firestore.firestore()
    
    init(PlantName: String) {
        getPlants(named: PlantName)
    }
    
    func toggleFavorite(userId: String, plantId: String) {
        isFavorite.toggle()
        if isFavorite {
            addFavoritePlant(userId: userId, plantId: plantId)
        } else {
            removeFavoritePlant(userId: userId, plantId: plantId)
        }
    }

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
