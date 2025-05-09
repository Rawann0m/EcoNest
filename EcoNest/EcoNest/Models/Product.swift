//
//  Product.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import Foundation

struct Product: Identifiable, Codable {
    
    var id: String
    var name: String
    var description: String
    var price: Double
    var image: String
    var category: String
    var quantity: Int
    var careLevel: String
    var color: String
    var size: String
    
    var isAddedToCart: Bool = false
}
