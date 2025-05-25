//
//  ProductDetailsViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import FirebaseFirestore

final class ProductDetailsViewModel: ObservableObject {
    @Published var product: Product?
    @Published var errorMessage: String?
    @Published var availableSizes: [Product] = []
    @Published var selectedProductId: String?

    private let db = Firestore.firestore()

    func fetchProductDetails(productId: String) {
        db.collection("product").document(productId)
            .getDocument(as: Product.self) { result in
                switch result {
                case .success(let product):
                    DispatchQueue.main.async {
                        self.product = product
                        self.fetchProductSizes(plantId: product.plantId ?? "", currentSize: product.size ?? "")
                        self.selectedProductId = nil
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }

    func fetchProductSizes(plantId: String, currentSize: String) {
        db.collection("product")
            .whereField("plantId", isEqualTo: plantId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching sizes: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No products found.")
                    return
                }

                let products = documents.compactMap { try? $0.data(as: Product.self) }

                DispatchQueue.main.async {
                    self.availableSizes = products
                }
            }
    }
}
