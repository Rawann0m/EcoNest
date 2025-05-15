//
//  Plant.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 14/05/2025.
//


import Foundation
import FirebaseFirestore

struct Plant: Codable {
    let name: String
    let description: String
    let water: String
    let light: String
    let image: String
    let category: [String]
}

struct PlantWrapper: Codable {
    let plants: [String: Plant]
}



class FireStoreUploader {
    
    // use this code in your page
    
//    @State private var uploader = FireStoreUploader()

    
//    Button("Check JSON File") {
//        if let url = Bundle.main.url(forResource: "plants", withExtension: "json") {
//            print("✅ Found JSON file at: \(url)")
//        } else {
//            print("❌ JSON file not found!")
//        }
//    }
//    
//    Button("Upload Plants") {
//        if let plants = uploader.loadPlantsFromJSON() {
//            uploader.uploadPlantsToFirestore(plants: plants)
//        }
//    }
    
    func loadPlantsFromJSON() -> [Plant]? {
        guard let url = Bundle.main.url(forResource: "plants", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load JSON file.")
            return nil
        }

        do {
            let wrapper = try JSONDecoder().decode(PlantWrapper.self, from: data)
            return Array(wrapper.plants.values)
        } catch {
            print("❌ Failed to decode JSON: \(error)")
            return nil
        }
    }


    func uploadPlantsToFirestore(plants: [Plant]) {
        let db = Firestore.firestore()

        for plant in plants {
            do {
                try db.collection("plantsDetails").addDocument(from: plant)
            } catch {
                print("❌ Error uploading plant: \(error)")
            }
        }
    }
}
