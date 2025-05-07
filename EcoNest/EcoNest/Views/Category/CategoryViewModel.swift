//
//  CategoryViewModel.swift
//  EcoNest
//
//  Created by Mac on 08/11/1446 AH.
//
import Foundation

class CategoryViewModel: ObservableObject {
    @Published var searchText = ""
    
    @Published var categories: [Category] = [
        Category(name: "African Violet", imageName: "african_violet"),
        Category(name: "Chrysanthemum", imageName: "chrysanthemum"),
        Category(name: "Anthurium", imageName: "anthurium"),
        Category(name: "Begonia", imageName: "begonia"),
        Category(name: "Bird of Paradise", imageName: "bird_of_paradise"),
        Category(name: "Christmas Cactus", imageName: "christmas_cactus"),
        Category(name: "Daffodils", imageName: "daffodils")
    ]

    

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

