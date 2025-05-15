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
    
    /// Products filtered based on the search query
    @Published var filtered: [Product] = []
    
    /// Computed property returning the first few product image URLs for slider
    var sliderImages: [String] {
        return products.prefix(4).map { $0.image }
    }
    
    /// Fetches product data from the "ProductTH" collection in Firestore
    func fetchProductData() {
        let db = FirebaseManager.shared.firestore
        
        db.collection("ProductTH").getDocuments { (snapshot, error) in
            guard let itemData = snapshot else { return }
            
            // Convert Firestore documents into Product models
            self.products = itemData.documents.compactMap { document in
                let id = document.documentID
                let name = document.get("name") as? String ?? ""
                let description = document.get("description") as? String ?? ""
                let price = document.get("price") as? Double ?? 0.0
                let image = document.get("image") as? String ?? ""
                let category = document.get("category") as? String ?? ""
                let quantity = document.get("quantity") as? Int ?? 0
                let careLevel = document.get("careLevel") as? String ?? ""
                let color = document.get("color") as? String ?? ""
                let size = document.get("size") as? String ?? ""
                
                // Construct and return a Product instance
                return Product(
                    id: id,
                    name: name,
                    description: description,
                    price: price,
                    image: image,
                    category: category,
                    quantity: quantity,
                    careLevel: careLevel,
                    color: color,
                    size: size
                )
            }
            
            // Initialize the filtered list to show all products
            self.filtered = self.products
        }
    }
    
    /// Filters the product list based on the current search query
    func filterData() {
        withAnimation(.spring) {
            self.filtered = self.products.filter {
                $0.name.lowercased().contains(self.search.lowercased())
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
                "productId": product.id,
                "quantity": 1,
                "price": product.price
            ]) { err in
                if let err = err {
                    print("Error adding to cart: \(err.localizedDescription)")
                }
            }
    }

}



