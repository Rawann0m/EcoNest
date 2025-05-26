//
//  Cart.swift
//  EcoNest
//
//  Created by Tahani Ayman on 12/11/1446 AH.
//

import Foundation

/// A model representing a cart item that the user has added.
struct Cart: Identifiable, Codable {
    
    var id: String
    var product: Product
    var quantity: Int
    var price: Double
}

