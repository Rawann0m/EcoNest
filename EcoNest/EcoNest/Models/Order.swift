//
//  Order.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import Foundation

/// Define a struct to represent an order, conforming to the Identifiable protocol
struct Order: Identifiable {
    
    var id: String
    var products: [Product]
    var total: Double
    var date: Date
    var pickupLocation: Location
    var status: OrderStatus
}



