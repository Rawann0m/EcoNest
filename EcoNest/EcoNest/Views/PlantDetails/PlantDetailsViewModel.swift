//
//  PlantDetailsViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 20/05/2025.
//

import FirebaseFirestore
import SwiftUI

class PlantDetailsViewModel: ObservableObject {
    @Published var plants : [Plant] = []
    
    private var db = Firestore.firestore()
    
    init() {
        getPlants()
    }
    
    func getPlants() {
        db.collection("plantsDetails").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❗️No documents found")
                return
            }
            
            DispatchQueue.main.async {
                self.plants = documents.compactMap { document in
                    try? document.data(as: Plant.self)
                }
            }
        }
    }
}
