//
//  OrderViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import Foundation
import FirebaseFirestore

/// ViewModel responsible for managing the list of orders.
class OrderViewModel: ObservableObject {
    
    /// List of orders fetched from Firestore.
    @Published var orders: [Order] = []
    
    /// Flag indicating whether the orders are currently being loaded.
    @Published var isLoading = false
    
    /// The currently selected order status category (e.g. Awaiting Pickup, Cancelled).
    @Published var selectedCategory: OrderStatus = .awaitingPickup

    /// Fetches the user's orders from Firestore in real-time and parses them into Order objects.
    func fetchOrders() {
        
        self.isLoading = true

        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        userDoc.collection("orders").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Failed to fetch orders: \(error.localizedDescription)")
                self.isLoading = false
                return
            }

            guard let documents = snapshot?.documents else {
                print("No orders found.")
                self.isLoading = false
                return
            }

            // Decode orders using Firestore's Codable decoding
            let fetchedOrders: [Order] = documents.compactMap { doc in
                try? doc.data(as: Order.self)
            }

            DispatchQueue.main.async {
                self.orders = fetchedOrders
                self.isLoading = false
            }
        }
    }

    /// Cancels a given order by updating its status in Firestore,
    /// and restores the product quantities back to inventory.
    /// - Parameter order: The order to be canceled
    func cancelOrders(order: Order) {
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        guard let orderId = order.id else {
            print("Missing order ID.")
            return
        }

        userDoc.collection("orders").document(orderId).updateData([
            "status": OrderStatus.cancelled.rawValue
        ]) { error in
            if let error = error {
                print("Failed to cancel order: \(error.localizedDescription)")
            } else {
                print("Order successfully cancelled.")
                self.restoreQuantity(order: order)
            }
        }
    }

    /// Restores product quantities in inventory for a cancelled order.
    /// - Parameter order: The cancelled order whose product stock needs to be restored.
    private func restoreQuantity(order: Order) {
        let db = FirebaseManager.shared.firestore

        for product in order.products {
            guard let productId = product.id else {
                print("Missing product ID")
                continue
            }

            let productRef = db.collection("product").document(productId)

            productRef.getDocument { document, error in
                if let document = document, document.exists,
                   let data = document.data(),
                   let currentQuantity = data["quantity"] as? Int {

                    let newQuantity = currentQuantity + (product.quantity ?? 0)

                    productRef.updateData(["quantity": newQuantity]) { error in
                        if let error = error {
                            print("Failed to restore quantity: \(error.localizedDescription)")
                        } else {
                            print("Successfully restored quantity")
                        }
                    }
                } else {
                    print("Failed to get product document")
                }
            }
        }
    }
}
