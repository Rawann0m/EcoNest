//
//  Plant.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import Foundation

struct Plant: Codable {
    let name: String
    let description: String
    let water: String
    let light: String
    let image: String
    let category: [String]
}

struct PlantWrapper: Codable {
    let plants: [String: Plant]
}
