//
//  Plant.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import Foundation
import FirebaseFirestore

struct Plant: Identifiable, Codable, Hashable{
    @DocumentID var id: String?
    let name: String
    let description: String
    let water: Double
    let light: Double
    let image: String
    let category: [String]
}

struct PlantWrapper: Codable {
    let plants: [String: Plant]
}
