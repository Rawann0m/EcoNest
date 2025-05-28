//
//  ProductDetailsViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import FirebaseFirestore

/// View model responsible for loading and managing product details and size variations.
///
/// `ProductDetailsViewModel` fetches a product from Firestore by its ID and retrieves
/// all available sizes for the same plant, allowing UI to support size selection.
final class ProductDetailsViewModel: ObservableObject {
    
    /// The currently selected product.
    @Published var product: Product?
    
    /// Error message to display in the UI if the fetch fails.
    @Published var errorMessage: String?
    
    /// All size variants of the product for the same plant.
    @Published var availableSizes: [Product] = []
    
    /// ID of the product the user selected from available sizes.
    @Published var selectedProductId: String?
    
    /// Firestore database reference.
    private let db = Firestore.firestore()
    
    /// Fetches a product document by ID and updates related size options.
    /// - Parameter productId: Firestore document ID of the product.
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
    
    /// Loads all size variants for a given plant ID.
    /// - Parameters:
    ///   - plantId: The plant’s unique identifier (shared across sizes).
    ///   - currentSize: The size of the currently viewed product (optional filtering).
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
