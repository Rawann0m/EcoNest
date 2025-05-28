//
//  Order.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import Foundation

/// A model representing a customer's order.
struct Order: Identifiable {
    
    var id: String
    var products: [Product]
    var total: Double
    var date: Date
    var pickupLocation: Location
    var status: OrderStatus
}


