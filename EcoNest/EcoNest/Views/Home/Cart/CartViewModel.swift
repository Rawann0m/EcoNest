//
//  CartViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// ViewModel responsible for managing cart-related operations.
class CartViewModel: ObservableObject {
    
    // Published properties to notify SwiftUI views of changes
    @Published var cartProducts: [Cart] = []
    @Published var isLoading = false
    @Published var selectedDate: Date = Date()

    private var cartListener: ListenerRegistration? // Listener for real-time cart updates
    private var authListener: AuthStateDidChangeListenerHandle? // Listener for auth state changes

    
    /// Initializes the view model and sets up a Firebase Auth listener
    init() {
        // Add a listener to monitor authentication state changes
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            // Use [weak self] to prevent retain cycles
            guard let self = self else { return }

            // If the user logs out, clear cart data and remove cart listener
            if user == nil {
                self.cartProducts = []
                self.cartListener?.remove()
            } else {
                self.fetchCartData() // Fetch cart data from Firestore for the logged-in user
            }
        }
    }

    
    /// Fetches the user's cart data from Firestore and listens for real-time updates.
    func fetchCartData() {
        isLoading = true
        cartListener?.remove()

        let db = FirebaseManager.shared.firestore
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        cartListener = userDoc
            .collection("cart")
            .order(by: FieldPath.documentID())
            .addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No cart data found.")
                self.isLoading = false
                return
            }

            var fetchedCart: [Cart] = []
            let group = DispatchGroup()

            for doc in documents {
                let data = doc.data()

                guard let productId = data["productId"] as? String,
                      let quantity = data["quantity"] as? Int,
                      let price = data["price"] as? Double else { continue }

                group.enter()

                db.collection("product").document(productId).getDocument { productDoc, error in
                    defer { group.leave() }

                    if let productDoc = productDoc, productDoc.exists {
                        let product = try? productDoc.data(as: Product.self)

                        if let product = product {
                            let cartItem = Cart(
                                id: doc.documentID,
                                product: product,
                                quantity: quantity,
                                price: price
                            )
                            fetchedCart.append(cartItem)
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.cartProducts = fetchedCart
                self.isLoading = false
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
            price += Double(cartItem.quantity) * (cartItem.product.price ?? 0)
        }
        return price
    }
    
    
    /// Adds a new order to the user's "orders" collection in Firestore.
    /// - Parameter locationId: The ID of the selected pickup location.
    func addOrder(locationId: String) {
        
        // Ensure user is logged in before proceeding
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        // Converts the product items into a dictionary format for Firestore.
        let productData = cartProducts.map { cart in
            return [
                "name": cart.product.name ?? "",
                "price": cart.price,
                "quantity": cart.quantity,
                "image": cart.product.image ?? "",
                "size": cart.product.size ?? "",
            ]
        }

        // Add the new order to the user's orders collection
        userDoc
            .collection("orders")
            .document()
            .setData([
                "products": productData,
                "total": calculateTotal(),
                "date": Timestamp(date: selectedDate),
                "pickupLocation": locationId,
                "status": OrderStatus.awaitingPickup.rawValue
            ]) { error in
                if let error = error {
                    print("Failed to place order: \(error.localizedDescription)")
                    return
                }
                
                // Update inventory quantities for ordered products
                self.reduceQuantity()

                // Clear cart after order placement and inventory update
                self.clearCartFromFirestore()
            }
    }
    
    
    /// Updates product inventory in Firestore by reducing quantity based on the user's cart.
    private func reduceQuantity() {
        
        let db = FirebaseManager.shared.firestore
        
        for cart in self.cartProducts {
            
            let productCollection = db.collection("product").document(cart.product.id ?? "")
            
            // Fetch the current product document
            productCollection.getDocument { document, error in
                if let document = document, document.exists,
                   let data = document.data(),
                   let currentQuantity = data["quantity"] as? Int {
                    
                    // Calculate the new quantity, ensuring it doesn't go below 0
                    let newQuantity = max(currentQuantity - cart.quantity, 0)
                    
                    // Update Firestore with the new quantity
                    productCollection.updateData(["quantity": newQuantity]) { error in
                        if let error = error {
                            print("Failed to update product quantity: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    
    /// Clears the current user's cart from Firestore and updates the local cart state.
    private func clearCartFromFirestore() {
        
        // Get the document reference for the current user; exit if not available
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        // Access the "cart" subcollection for the current user
        userDoc
            .collection("cart")
            .getDocuments { snapshot, error in
                // Check if documents were retrieved successfully
                guard let documents = snapshot?.documents else {
                    print("No cart items found.")
                    return
                }
                
                // Iterate through each document (cart item) and delete it
                for doc in documents {
                    doc.reference.delete()
                }
                
                // Clear the local cart state on the main thread
                DispatchQueue.main.async {
                    self.cartProducts.removeAll() // Clear local cart as well
                }
                
                print("Cart cleared after order placement.")
            }
    }

    
    /// Updates the quantity of a specific cart item in both local state and Firestore.
    /// - Parameters:
    ///   - cart: The cart item to be updated.
    ///   - change: A Boolean indicating whether to increment (true) or decrement (false) the quantity.
    func updateQuantity(cart: Cart, change: Bool) {
        
        // Find the index of the cart item in the local array; exit if not found
        guard let index = cartProducts.firstIndex(where: { $0.id == cart.id }) else { return }
        
        // Get the document reference for the current user; exit if not available
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        // Adjust the quantity locally based on the change flag
        if change {
            cartProducts[index].quantity += 1
        } else {
            cartProducts[index].quantity -= 1
        }
        
        // Update the corresponding cart document in Firestore with the new quantity
        userDoc
            .collection("cart")
            .document(cart.id)
            .updateData([
                "quantity": cartProducts[index].quantity
            ]) { error in
                if let error = error {
                    print("Failed to update quantity: \(error.localizedDescription)")
                }
            }
    }


    /// Removes an item from the user's cart in Firestore and updates the local cart state.
    /// - Parameter index: An IndexSet indices of items to remove.
    func removeFormCart(index: IndexSet) {
        
        // Get the document reference for the current user; exit if not available
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        // Safely extract the first index from the IndexSet and check bounds
        guard let i = index.first, i < cartProducts.count else {
            print("Invalid index")
            return
        }
        
        // Delete the item from the Firestore cart collection
        userDoc
            .collection("cart")
            .document(cartProducts[i].id) // Retrieve the cart item id to be deleted
            .delete { err in
                if let err = err {
                    print("Failed to delete from cart: \(err.localizedDescription)")
                    return
                }

                // Update the local cart on the main thread after successful deletion
                DispatchQueue.main.async {
                    if self.cartProducts.indices.contains(i) {
                           self.cartProducts.remove(at: i)
                       }
                }
            }
    }


    /// Removes a specific cart item from the user's Firestore cart and updates the local cart state.
    /// - Parameter cart: The cart item to be removed.
    func removeFormCart(cart: Cart) {
        
        // Get the document reference for the current user; exit if not available
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        // Delete the specific cart item document from the "cart" subcollection in Firestore
        userDoc
            .collection("cart")
            .document(cart.id)
            .delete { err in
                if let err = err {
                    print("Failed to delete cart item: \(err.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    // Remove any item with the same ID from the local cart
                    self.cartProducts.removeAll { $0.id == cart.id }
                }
            }
    }

}
