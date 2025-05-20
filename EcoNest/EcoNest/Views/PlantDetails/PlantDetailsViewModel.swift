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
    
    private var db = Firestore.firestore()
    
    init(PlantName: String) {
        getPlants(named: PlantName)
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
                    DispatchQueue.main.async {
                        self.plant = fetchedPlant
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                }
            }
    }
}
