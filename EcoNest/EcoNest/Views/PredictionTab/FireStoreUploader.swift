//
//  Plant.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 14/05/2025.
//


import Foundation
import FirebaseFirestore



class FireStoreUploader {
    
//    Button("Check JSON File") {
//        if let url = Bundle.main.url(forResource: "plants", withExtension: "json") {
//            print("✅ Found JSON file at: \(url)")
//        } else {
//            print("❌ JSON file not found!")
//        }
//    }
//    
  
    
    func loadPlantsFromJSON() -> [Product]? {
    guard let url = Bundle.main.url(forResource: "products", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        print("❌ Failed to load JSON file.")
        return nil
    }

    do {
        let products = try JSONDecoder().decode([Product].self, from: data)
        print("✅ Decoded \(products.count) products")
        return products
    } catch {
        print("❌ Failed to decode JSON: \(error)")
        return nil
    }
}




    func uploadPlantsToFirestore(products: [Product], completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        var errors: [Error] = []
        let group = DispatchGroup()

        for var product in products {
            group.enter()
            let docRef = db.collection("product").document()
            product.id = docRef.documentID

            do {
                try docRef.setData(from: product) { error in
                    if let error = error {
                        errors.append(error)
                    }
                    group.leave()
                }
            } catch {
                errors.append(error)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(errors.first!))
            }
        }
    }



}
