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
    
    // Published properties
    @Published private var cartProductsRaw: [Cart] = []
    @Published var isLoading = false
    @Published var selectedDate: Date = Date()
    
    // Computed property for sorted view
    var cartProducts: [Cart] {
        cartProductsRaw.sorted { $0.id < $1.id }
    }

    private var cartListener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if user == nil {
                self.cartProductsRaw = []
                self.cartListener?.remove()
            } else {
                self.fetchCartData()
            }
        }
    }

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
                    self.cartProductsRaw = fetchedCart
                    self.isLoading = false
                }
            }
    }

    func calculateTotal() -> Double {
        cartProducts.reduce(0) { total, item in
            total + Double(item.quantity) * (item.product.price ?? 0)
        }
    }

    func addOrder(locationId: String) {
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        let productData = cartProducts.map {
            [
                "name": $0.product.name ?? "",
                "price": $0.price,
                "quantity": $0.quantity,
                "image": $0.product.image ?? "",
                "size": $0.product.size ?? ""
            ]
        }

        userDoc.collection("orders").document().setData([
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

            self.reduceQuantity()
            self.clearCartFromFirestore()
        }
    }

    private func reduceQuantity() {
        let db = FirebaseManager.shared.firestore

        for cart in cartProducts {
            guard let productId = cart.product.id else { continue }
            let productRef = db.collection("product").document(productId)

            productRef.getDocument { document, error in
                if let document = document, document.exists,
                   let data = document.data(),
                   let currentQuantity = data["quantity"] as? Int {
                    let newQuantity = max(currentQuantity - cart.quantity, 0)

                    productRef.updateData(["quantity": newQuantity]) { error in
                        if let error = error {
                            print("Failed to update product quantity: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    private func clearCartFromFirestore() {
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        userDoc.collection("cart").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No cart items found.")
                return
            }

            for doc in documents {
                doc.reference.delete()
            }

            DispatchQueue.main.async {
                self.cartProductsRaw.removeAll()
                print("Cart cleared after order placement.")
            }
        }
    }

    func updateQuantity(cart: Cart, change: Bool) {
        guard let index = cartProductsRaw.firstIndex(where: { $0.id == cart.id }) else { return }
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        if change {
            cartProductsRaw[index].quantity += 1
        } else {
            cartProductsRaw[index].quantity = max(cartProductsRaw[index].quantity - 1, 1)
        }

        userDoc.collection("cart")
            .document(cart.id)
            .updateData(["quantity": cartProductsRaw[index].quantity]) { error in
                if let error = error {
                    print("Failed to update quantity: \(error.localizedDescription)")
                }
            }
    }

    func removeFormCart(index: IndexSet) {
        guard let i = index.first else { return }
        let itemToRemove = cartProducts[i]
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        userDoc.collection("cart")
            .document(itemToRemove.id)
            .delete { err in
                if let err = err {
                    print("Failed to delete from cart: \(err.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    self.cartProductsRaw.removeAll { $0.id == itemToRemove.id }
                }
            }
    }
    
    /// Removes a specific cart item from the user's Firestore cart and updates the local cart state.
    /// - Parameter cart: The cart item to be removed.
    func removeFormCart(cart: Cart) {
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        userDoc.collection("cart")
            .document(cart.id)
            .delete { err in
                if let err = err {
                    print("Failed to delete cart item: \(err.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    self.cartProductsRaw.removeAll { $0.id == cart.id }
                }
            }
    }
}
