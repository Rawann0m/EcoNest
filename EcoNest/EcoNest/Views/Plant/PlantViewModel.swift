//
//  PlantViewModel.swift
//  EcoNest
//
//  Created by Mac on 20/11/1446 AH.
//

import Foundation
import FirebaseFirestore

class PlantViewModel: ObservableObject {
    @Published var allPlants: [Plant] = []              // All plants fetched from Firestore
    @Published var filteredPlants: [Plant] = []         // Filtered result to display
    @Published var searchText = ""                      // Search query
    @Published var selectedCategories: [String] = []    // Categories selected in filter
    
    let allCategories = [ // Available categories
        "🌿 Foliage Plants", "🌸 Flowering Plants", "🌴 Palms & Palm-like",
        "🌵 Succulents & Cacti", "🍃 Ferns", "🪴 Air-Purifying",
        "☠️ Toxic Plants", "✅ Beginner-friendly", "🌱 Specialty / Unique"
    ]
    
    init() {
        fetchPlants()
    }
    
    // Fetch plant data from Firestore
    func fetchPlants() {
        let db = Firestore.firestore()
        db.collection("plantsDetails").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            let fetchedPlants = documents.compactMap { try? $0.data(as: Plant.self) }
            DispatchQueue.main.async {
                self.allPlants = fetchedPlants
                self.applyFilters()
            }
        }
    }
    
    // Apply search and category filters
    func applyFilters() {
        var result = allPlants
        
        // Filter by selected categories
        if !selectedCategories.isEmpty {
            result = result.filter { plant in
                !Set(plant.category).isDisjoint(with: selectedCategories)
            }
        }
        
        // Filter by search keyword
        if !searchText.isEmpty {
            result = result.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        filteredPlants = result
    }
}
