//
//  CartViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import Foundation

class CartViewModel: ObservableObject {
    
    @Published var cartProducts: [Cart] = []
    
    func addToCart(product: Product) {
        if let index = cartProducts.firstIndex(where: { $0.product.id == product.id }) {
            cartProducts.remove(at: index)
        } else {
            cartProducts.append(Cart(product: product, quantity: 1))
        }
        
        saveCartToDefaults()
    }

    func loadCartFromDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "savedCart"),
           let decoded = try? JSONDecoder().decode([Cart].self, from: savedData) {
            self.cartProducts = decoded
        }
    }

    func saveCartToDefaults() {
        if let encoded = try? JSONEncoder().encode(cartProducts) {
            UserDefaults.standard.set(encoded, forKey: "savedCart")
        }
    }
}

