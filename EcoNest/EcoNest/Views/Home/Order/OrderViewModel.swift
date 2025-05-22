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

class OrderViewModel: ObservableObject {
    
    @Published var orders: [Order] = []
    @Published var isLoading = false
    
    func fetchOrders() {
        
        isLoading = true
        
        let db = FirebaseManager.shared.firestore
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }

        db.collection("users")
            .document(userId)
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
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let id = doc.documentID
                    let total = data["total"] as? Double ?? 0.0
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    let statusString = data["status"] as? String ?? ""
                    let status = OrderStatus(rawValue: statusString) ?? .awaitingPickup
                    let pickupLocationId = data["pickupLocation"] as? String ?? ""
                    let productDicts = data["products"] as? [[String: Any]] ?? []

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

                group.notify(queue: .main) {
                    self.orders = fetchedOrders
                    self.isLoading = false
                }
            }
    }
    
    func cancelOrders(order: Order) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User must be logged in to cancel orders.")
            return
        }

        let db = FirebaseManager.shared.firestore
        
        db.collection("users")
            .document(userId)
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

