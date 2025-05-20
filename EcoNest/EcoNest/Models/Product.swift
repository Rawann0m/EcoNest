//
//  Product.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    var id: String?
    var plantId: String?
    var name: String?
    var description: String?
    var price: Double?
    let plantId: String?
    var image: String?
    var category: [String]?
    var quantity: Int?
    var careLevel: String?
    var size: String?
}

struct ProductWrapper: Codable {
    let products: [Product]
}
