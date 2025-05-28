//
//  Category.swift
//  EcoNest
//
//  Created by Mac on 08/11/1446 AH.
//

import Foundation

// Represents a specific plant that belongs to a CategoryType
struct Category: Identifiable, Codable {
    var id: String     // Unique ID for this category
    var name: String                       // Name of the plant (e.g., "Anthurium")
    var imageName: String                  // Name of the image asset for the plant
    var typeId: String                     // Foreign key: links to the CategoryType ID
}
