//
//  Product.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import Foundation
import FirebaseFirestore

// Struct to represent a product, conforming to Identifiable and Codable protocols
struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var plantId: String?
    var name: String?
    var description: String?
    var price: Double?
    var image: String?
    var category: [String]?
    var quantity: Int?
    var careLevel: String?
    var size: String?
}


struct ProductWrapper: Codable {
    let products: [Product]
}
