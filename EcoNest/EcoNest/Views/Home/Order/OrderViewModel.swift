//
//  OrderViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import MapKit

/// ViewModel responsible for managing the list of orders, their statuses, and interactions like cancellation.
class OrderViewModel: ObservableObject {
    
    /// List of orders fetched from Firestore.
    @Published var orders: [Order] = []
    
    /// Flag indicating whether the orders are currently being loaded.
    @Published var isLoading = false
    
    /// Controls the presentation of the cancel confirmation alert.
    @Published var showCancelAlert = false
    
    /// The currently selected order status category.
    @Published var selectedCategory: OrderStatus = .awaitingPickup

    
    /// Fetches the user's orders from Firestore.
    func fetchOrders() {
        
        isLoading = true
        
        let db = FirebaseManager.shared.firestore
        
        // Ensure the user is logged in
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }

        // Listen for real-time updates to the "orders" collection
        userDoc
            .collection("orders")
            .addSnapshotListener { snapshot, error in
                
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

                var fetchedOrders: [Order] = []
                let group = DispatchGroup() // Used to wait for all async location fetches to complete

                for doc in documents {
                    let data = doc.data()
                    let id = doc.documentID
                    
                    // Extract order fields
                    let total = data["total"] as? Double ?? 0.0
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    let statusString = data["status"] as? String ?? ""
                    let status = OrderStatus(rawValue: statusString) ?? .awaitingPickup
                    let pickupLocationId = data["pickupLocation"] as? String ?? ""
                    let productDicts = data["products"] as? [[String: Any]] ?? []

                    // Decode product list
                    var products: [Product] = []
                    for productData in productDicts {
                        let product = Product(
                            name: productData["name"] as? String ?? "",
                            price: productData["price"] as? Double ?? 0.0,
                            image: productData["image"] as? String ?? "",
                            quantity: productData["quantity"] as? Int ?? 1,
                            size: productData["size"] as? String ?? ""
                        )
                        products.append(product)
                    }

                    // Fetch related pickup location
                    group.enter()
                    db.collection("pickupLocations")
                        .document(pickupLocationId)
                        .getDocument { locationDoc, error in
                            defer { group.leave() }

                            guard let locationDoc = locationDoc, locationDoc.exists,
                                  let locationData = locationDoc.data() else {
                                print("Failed to fetch location for order \(id)")
                                return
                            }

                            // Convert Firestore location data to Location struct
                            let coordinates = CLLocationCoordinate2D(
                                latitude: locationData["latitude"] as? CLLocationDegrees ?? 0.0,
                                longitude: locationData["longitude"] as? CLLocationDegrees ?? 0.0
                            )

                            let location = Location(
                                id: pickupLocationId,
                                name: locationData["name"] as? String ?? "",
                                description: locationData["description"] as? String ?? "",
                                coordinates: coordinates,
                                image: locationData["image"] as? String ?? ""
                            )

                            // Assemble the complete Order object
                            let order = Order(
                                id: id,
                                products: products,
                                total: total,
                                date: date,
                                pickupLocation: location,
                                status: status
                            )

                            fetchedOrders.append(order)
                        }
                }

                // Once all locations have been fetched, update the published orders list
                group.notify(queue: .main) {
                    self.orders = fetchedOrders
                    self.isLoading = false
                }
            }
    }

    /// Cancels a given order by updating its status in Firestore.
    /// - Parameter order: The order to be canceled
    func cancelOrders(order: Order) {
        guard let userDoc = FirebaseManager.shared.getCurrentUser() else { return }
        
        userDoc
            .collection("orders")
            .document(order.id)
            .updateData([
                "status": OrderStatus.cancelled.rawValue
            ]) { error in
                if let error = error {
                    print("Failed to cancel order: \(error.localizedDescription)")
                } else {
                    print("Order successfully cancelled.")
                }
            }
    }
}


