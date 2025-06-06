//
//  CartProductRow.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A reusable SwiftUI view that displays a single cart item row,
/// including product image, name, price, and quantity controls.
struct CartProductRow: View {
    
    /// View model responsible for cart interactions.
    @ObservedObject var viewModel: CartViewModel
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// The cart item to be displayed in the row.
    var cartProduct: Cart
    
    @State private var showOutOfStockAlert = false

    var currentLanguage: String
    
    var body: some View {
        
        HStack(spacing: 15) {
            
            // Product image
            WebImage(url: URL(string: cartProduct.product.image ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(.gray.opacity(0.15))
                .frame(width: 70, height: 80)
                .cornerRadius(8)
                
            
            // Product name and price
            VStack(alignment: .leading, spacing: 8) {
                
                // Display product name
                Text(cartProduct.product.name ?? "")
                
                Text(cartProduct.product.size ?? "")
                    .font(.caption)
                // Display product price with currency icon
                HStack {
                    
                    Text("\(cartProduct.price, specifier: "%.2f")")
                        .bold()
                    
                    // Display a currency icon based on theme mode
                    Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            VStack {
                // Quantity adjustment section (increase, decrease, or remove)
                HStack(spacing: 5) {
                    
                    // Increase quantity button
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .onTapGesture {
                            if cartProduct.quantity != cartProduct.product.quantity {
                                viewModel.updateQuantityLocally(cart: cartProduct, change: true)
                            } else {
                                showOutOfStockAlert = true
                            }
                        }
                        .alert("OutofStock".localized(using: currentLanguage), isPresented: $showOutOfStockAlert) {
                            Button("OK".localized(using: currentLanguage), role: .cancel) {}
                        } message: {
                            Text("ProductOutStock".localized(using: currentLanguage))
                        }
                    
                    // Display current quantity
                    Text("\(cartProduct.quantity)")
                        .font(.headline)
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    
                    // Decrease quantity or remove item if quantity is 1
                    Image(systemName: cartProduct.quantity > 1 ? "minus.circle.fill" : "trash.circle.fill")
                        .font(.system(size: 24))
                        .onTapGesture {
                            if cartProduct.quantity > 1 {
                                viewModel.updateQuantityLocally(cart: cartProduct, change: false)
                            } else {
                                viewModel.removeFormCart(cart: cartProduct)
                            }
                        }
        
                }
                .foregroundStyle(themeManager.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2))
                .font(.system(size: 20))
                
                if cartProduct.product.quantity ?? 0 <= 5 {
                    Spacer()
                        .frame(height: 30)
                    
                    Text("Only \(cartProduct.product.quantity ?? 0) Left")
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.5))
                }
            }
            
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(themeManager.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
