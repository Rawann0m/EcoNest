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
    @Published var allCategories: [String] = []  


    init() {
        fetchPlants()
    }
    
    // Fetch plant data from Firestore
    func fetchPlants() {
        let db = Firestore.firestore()
        db.collection("plantsDetails").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            let fetchedPlants = documents.compactMap { try? $0.data(as: Plant.self) }

            let categoriesSet = Set(fetchedPlants.flatMap { $0.category })
            let sortedCategories = Array(categoriesSet).sorted()

            DispatchQueue.main.async {
                self.allPlants = fetchedPlants
                self.allCategories = sortedCategories
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
