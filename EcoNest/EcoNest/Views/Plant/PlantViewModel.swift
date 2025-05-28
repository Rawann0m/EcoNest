//
//  PlantViewModel.swift
//  EcoNest
//
//  Created by Mac on 20/11/1446 AH.
//

import Foundation
import FirebaseFirestore

/// ViewModel to manage and filter plant data from Firestore
class PlantViewModel: ObservableObject {
    
    @Published var allPlants: [Plant] = []              // All plants fetched from Firestore
    @Published var filteredPlants: [Plant] = []         // Plants filtered by search and category
    @Published var searchText = ""                      // User's search query
    @Published var selectedCategories: [String] = []    // Currently selected filter categories
    @Published var allCategories: [String] = []         // All available categories (for filter UI)

    // Called on initialization to load plant data
    init() {
        fetchPlants()
    }
    
    /// Fetch plant documents from the "plantsDetails" Firestore collection
    func fetchPlants() {
        let db = Firestore.firestore()
        db.collection("plantsDetails").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }

            // Map Firestore documents to Plant model
            let fetchedPlants = documents.compactMap { try? $0.data(as: Plant.self) }

            // Extract and sort unique categories from all fetched plants
            let categoriesSet = Set(fetchedPlants.flatMap { $0.category })
            let sortedCategories = Array(categoriesSet).sorted()

            // Update UI-related properties on the main thread
            DispatchQueue.main.async {
                self.allPlants = fetchedPlants
                self.allCategories = sortedCategories
                self.applyFilters()  // Apply any filters after data is loaded
            }
        }
    }

    /// Apply search and category-based filtering to all plants
    func applyFilters() {
        var result = allPlants
        
        // Filter by selected categories (intersection check)
        if !selectedCategories.isEmpty {
            result = result.filter { plant in
                !Set(plant.category).isDisjoint(with: selectedCategories)
            }
        }
        
        // Filter by search text (case insensitive match on name)
        if !searchText.isEmpty {
            result = result.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Update the filtered results to be displayed
        filteredPlants = result
    }
}
