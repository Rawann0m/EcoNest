//
//  HomeViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI
import FirebaseAuth

/// ViewModel for managing the home screen's product data, search functionality, and cart interactions.
class HomeViewModel: ObservableObject {
    
    /// The current search query entered by the user.
    @Published var search: String = ""
    
    /// All products fetched from Firestore.
    @Published var products: [Product] = []
    
    /// Products with the least quantity (used for the promotional image slider).
    @Published var leastProducts: [Product] = []
    
    /// Products filtered based on the user's search query.
    @Published var filtered: [Product] = []
    
    
    // MARK: - Firestore Fetching
    /// Fetches all product data from the "product" collection in Firestore where `quantity > 0`.
    func fetchProductData() {
        let db = FirebaseManager.shared.firestore
        
        db.collection("product")
            .whereField("quantity", isGreaterThan: 0)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Failed to fetch products: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Decode each Firestore document into a Product model
                self.products = documents.compactMap { document in
                    try? document.data(as: Product.self)
                }
                
                // Initialize the filtered list with all products
                self.filtered = self.products
            }
    }

    
    /// Fetches up to 4 products with the lowest quantity to use in a promotional image slider.
    func fetchLeasttQuantity() {
        let db = FirebaseManager.shared.firestore

        db.collection("product")
            .order(by: "quantity")
            .limit(to: 4)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Failed to fetch least quantity products: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Decode each Firestore document into a Product model
                self.leastProducts = documents.compactMap { document in
                    try? document.data(as: Product.self)
                }
            }
    }
    
    
    // MARK: - Search Filtering
    /// Filters the products array based on the current search query.
    func filterData() {
        withAnimation(.spring) {
            self.filtered = self.products.filter {
                // Case-insensitive matching on product name
                ($0.name?.lowercased().contains(self.search.lowercased())) ?? false
            }
        }
    }
    
    // MARK: - Cart Interaction
    /// Adds the given product to the current user's cart in Firestore.
    /// - Parameter product: The Product to be added to the cart.
    func addToCart(product: Product) {
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else {
            print("User not logged in.")
            return
        }
        
        userDoc
            .collection("cart")
            .document() 
            .setData([
                "productId": product.id ?? "",
                "quantity": 1,
                "price": product.price ?? 0.0
            ]) { error in
                if let error = error {
                    print("Error adding to cart: \(error.localizedDescription)")
                }
            }
    }
}
