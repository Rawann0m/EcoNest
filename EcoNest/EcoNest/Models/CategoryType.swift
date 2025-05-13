//
//  CategoryType.swift
//  EcoNest
//
//  Created by Mac on 13/11/1446 AH.
//


import Foundation

// Represents the main plant type (e.g., "Flowering Plants", "Succulents", etc.)
struct CategoryType: Identifiable, Codable , Hashable {
    var id: String      // Unique ID for Firestore and identification
    var name: String                       // Display name for the category type
    var imageName: String
}
