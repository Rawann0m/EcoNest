//
//  HomeViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI
import FirebaseAuth

/// ViewModel for managing the home screen's product data and search functionality
class HomeViewModel: ObservableObject {
    
    /// The current search query entered by the user
    @Published var search: String = ""
    
    /// All products fetched from Firestore
    @Published var products: [Product] = []
    @Published var leastProducts: [Product] = []
    
    /// Products filtered based on the search query
    @Published var filtered: [Product] = []
    
    
    init(){
        fetchProductData()
        fetchLeasttQuantity()
    }
    
    /// Computed property returning the first few product image URLs for slider
    var sliderImages: [(name: String?, image: String?)] {
        return leastProducts.map { ($0.name, $0.image ?? "") }
    }
    
    /// Fetches product data from the "product" collection in Firestore
    func fetchProductData() {
        let db = FirebaseManager.shared.firestore
        
        db.collection("product")
            .whereField("quantity", isGreaterThan: 0)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else { return }

                self.products = documents.compactMap { document in
                    try? document.data(as: Product.self)
                }

                self.filtered = self.products
            }
    }

    
    func fetchLeasttQuantity() {
        let db = FirebaseManager.shared.firestore

        db.collection("product")
            .order(by: "quantity") // Order by quantity ascending
            .limit(to: 4)          // Limit to 4 items
            .getDocuments { (snapshot, error) in
                guard let itemData = snapshot else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self.leastProducts = itemData.documents.compactMap { document in
                    try? document.data(as: Product.self)
                }
            }
    }

    
    /// Filters the product list based on the current search query
    func filterData() {
        withAnimation(.spring) {
            self.filtered = self.products.filter {
                ($0.name?.lowercased().contains(self.search.lowercased()))!
            }
       }
    }
    
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
            .document()
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



