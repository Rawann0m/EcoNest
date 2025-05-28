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
    
    /// Products with the least quantity (used for the image slider).
    @Published var leastProducts: [Product] = []
    
    /// Products filtered based on the search query.
    @Published var filtered: [Product] = []
    
    /// Initializes the view model and fetches product data.
    init() {
        fetchProductData()
        fetchLeasttQuantity()
    }
    
    // MARK: - Firestore Fetching
    
    /// Fetches all product data from the "product" collection in Firestore where quantity > 0.
    func fetchProductData() {
        let db = FirebaseManager.shared.firestore
        
        db.collection("product")
            .whereField("quantity", isGreaterThan: 0)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else { return }
                
                // Decode each document into a Product model
                self.products = documents.compactMap { document in
                    try? document.data(as: Product.self)
                }
                
                // Initially, filtered products = all products
                self.filtered = self.products
            }
    }

    /// Fetches up to 4 products with the least quantity to display in the image slider.
    func fetchLeasttQuantity() {
        let db = FirebaseManager.shared.firestore

        db.collection("product")
            .order(by: "quantity") // Ascending order by quantity
            .limit(to: 4)          // Limit results to 4 products
            .getDocuments { (snapshot, error) in
                guard let itemData = snapshot else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Decode each document into a Product model
                self.leastProducts = itemData.documents.compactMap { document in
                    try? document.data(as: Product.self)
                }
            }
    }
    
    // MARK: - Search Filtering
    
    /// Filters the product list based on the current search query.
    func filterData() {
        withAnimation(.spring) {
            self.filtered = self.products.filter {
                // Case-insensitive search within product names
                ($0.name?.lowercased().contains(self.search.lowercased())) ?? false
            }
        }
    }
    
    // MARK: - Cart Interaction
    
    /// Adds a product to the current user's cart in Firestore.
    /// - Parameter product: The product to be added to the cart.
    func addToCart(product: Product) {
        let db = FirebaseManager.shared.firestore
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User must be logged in to add to cart.")
            return
        }
        
        db.collection("users")
            .document(userId)
            .collection("cart")
            .document() // Auto-generated document ID
            .setData([
                "productId": product.id ?? "",
                "quantity": 1,
                "price": product.price ?? ""
            ]) { err in
                if let err = err {
                    print("Error adding to cart: \(err.localizedDescription)")
                }
            }
    }
}
