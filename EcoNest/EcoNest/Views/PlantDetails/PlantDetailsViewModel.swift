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
    
    private var db = Firestore.firestore()
    
    init(PlantName: String) {
        getPlants(named: PlantName)
    }
    
    @MainActor
    func fetchProducts(for plantId: String) async {
        print("🔍 Looking for products where plantId == \(plantId)")      // debug

        do {
            let snap = try await db.collection("product")
                                   .whereField("plantId", isEqualTo: plantId)
                                   .getDocuments()

            print("✅ Found \(snap.count) matching docs")            // debug
            products = try snap.documents.compactMap {
                         try $0.data(as: Product.self)
                     }

        } catch {
            print("❌ Product fetch error:", error.localizedDescription)
            products = []
        }
    }
    
    func getPlants(named PlantName: String) {
        
        Task {
            let snap = try await db.collection("product")
                                   .limit(to: 1)
                                   .getDocuments()

            if let doc = snap.documents.first {
                print("📝 Raw product:", doc.documentID, doc.data())
            }
        }
        
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
                        print("🌱 Plant docID decoded from @DocumentID:", id)   // <-- see this in console

                        Task { await self.fetchProducts(for: id) }
                    } else {
                        print("🚨 fetchedPlant.id is nil – @DocumentID not working?")
                    }
                    
                    
                } catch {
                    print("❌ Decoding error:", error)
                }
            }
    }
}
