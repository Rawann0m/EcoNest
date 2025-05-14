//
//  CartViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// ViewModel responsible for managing cart-related operations such as adding to and fetching from Firestore.
class CartViewModel: ObservableObject {
    
    /// List of cart items currently stored in Firestore for the user.
    @Published var cartProducts: [Cart] = []
    @Published var isLoading = false
    @Published var selectedDate: Date = Date()
    /// Fetches all cart items from Firestore and resolves them into complete Cart objects with full Product data.
    func fetchCartData() {
        isLoading = true
        let db = FirebaseManager.shared.firestore

        db.collection("users")
            .document("URsr5i4FLISZRfy4Ncm3g2cujVn2")
            .collection("cart")
            .getDocuments { snapshot, error in

                guard let documents = snapshot?.documents else {
                    print("No cart data found.")
                    DispatchQueue.main.async {
                        self.cartProducts = []
                        self.isLoading = false
                    }
                    return
                }

                self.cartProducts = [] // Clear previously loaded data

                // Track how many documents are processed
                var processedCount = 0

                for doc in documents {
                    let data = doc.data()

                    guard let productId = data["productId"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let price = data["price"] as? Double else {
                              processedCount += 1
                              continue
                          }

                    db.collection("ProductTH").document(productId).getDocument { productDoc, error in
                        if let productData = productDoc?.data() {
                            let product = Product(
                                id: productDoc!.documentID,
                                name: productData["name"] as? String ?? "",
                                description: productData["description"] as? String ?? "",
                                price: productData["price"] as? Double ?? 0.0,
                                image: productData["image"] as? String ?? "",
                                category: productData["category"] as? String ?? "",
                                quantity: productData["quantity"] as? Int ?? 0,
                                careLevel: productData["careLevel"] as? String ?? "",
                                color: productData["color"] as? String ?? "",
                                size: productData["size"] as? String ?? "",
                                isAddedToCart: true
                            )

                            let cartItem = Cart(
                                id: doc.documentID,
                                product: product,
                                quantity: quantity,
                                price: price
                            )

                            DispatchQueue.main.async {
                                self.cartProducts.append(cartItem)
                            }
                        }

                        processedCount += 1

                        // Once all documents are processed, stop loading
                        if processedCount == documents.count {
                            DispatchQueue.main.async {
                                self.isLoading = false
                            }
                        }
                    }
                }

                // Handle empty cart case immediately
                if documents.isEmpty {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
    }

    
    /// Calculates the total price of all items in the cart.
    /// - Returns: The sum of (quantity × unit price) for each cart item.
    func calculateTotal() -> Double {
        var price: Double = 0
        // Iterate through each cart item
        cartProducts.forEach { cartItem in
            // Multiply quantity by the product's price, then add to total
            price += Double(cartItem.quantity) * cartItem.product.price
        }
        return price
    }
    
    /// Remove items from the user's cart in Firestore and updates the local cart state.
    /// - Parameter index: An IndexSet containing the indices of items to remove.
    func removeFormCart(index: IndexSet) {
        let db = FirebaseManager.shared.firestore
        
        guard let i = index.first else { return }
        
        // Get the corresponding cart item using the index
        let cartItem = cartProducts[i]
        
        // Reference the Firestore document for the cart item and attempt deletion
        db.collection("users")
            .document("URsr5i4FLISZRfy4Ncm3g2cujVn2")
            .collection("cart")
            .document(cartItem.id)
            .delete { err in
                
                if let err = err {
                    // Print the error if deletion fails
                    print("Failed to delete from cart: \(err.localizedDescription)")
                    return
                }
                
                // If deletion is successful, remove the item from the local cart list on the main thread
                DispatchQueue.main.async {
                    self.cartProducts.remove(at: i)
                }
            }
    }
    
    /// Adds a new order to the user's "orders" collection in Firestore.
    /// - Parameter locationId: The ID of the selected pickup location.
    func addOrder(locationId: String) {
        
        // Reference to the Firestore database
        let db = FirebaseManager.shared.firestore
        
        // Prepare cart data in the format expected by Firestore
        let cartData = cartProducts.map { cart in
            return [
                "name": cart.product.name,
                "price": cart.price,
                "quantity": cart.quantity,
                "image": cart.product.image,
                "category": cart.product.category,
                "color": cart.product.color,
                "size": cart.product.size,
            ]
        }
        // Create a new document in the "orders" subcollection under the current user
        db.collection("users")
            .document("URsr5i4FLISZRfy4Ncm3g2cujVn2")
            .collection("orders")
            .document() // Generate a new document with a unique ID
            .setData([
                "products": cartData,
                "total": calculateTotal(),
                "date": Timestamp(date: selectedDate),
                "pickupLocation": locationId,
                "status" : OrderStatus.awaitingPickup.rawValue
            ]) { error in
                if let error = error {
                    print("Failed to place order: \(error.localizedDescription)")
                    return
                }

                // Order placed successfully — now delete all cart items
                self.clearCartFromFirestore(userId: "URsr5i4FLISZRfy4Ncm3g2cujVn2")
            }
    }
    
    private func clearCartFromFirestore(userId: String) {
        let db = FirebaseManager.shared.firestore

        db.collection("users")
            .document(userId)
            .collection("cart")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No cart items found.")
                    return
                }

                for doc in documents {
                    doc.reference.delete()
                }

                DispatchQueue.main.async {
                    self.cartProducts.removeAll() // Clear local cart as well
                }

                print("Cart cleared after order placement.")
            }
    }

}
