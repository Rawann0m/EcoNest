//
//  CartProductRow.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A reusable SwiftUI view that displays a single cart item row.
struct CartProductRow: View {
    
    /// The cart item to display.
    var cartProduct: Cart
    
    /// Environment object for theme customization.
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CartViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            // Product image loaded from a URL using SDWebImageSwiftUI
            WebImage(url: URL(string: cartProduct.product.image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(.gray.opacity(0.15))
                .frame(width: 70, height: 70)
                .cornerRadius(8)
                .transition(.fade(duration: 0.25))
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Product name
                Text(cartProduct.product.name)
                
                // Price with currency icon
                HStack {
                    Text("\(cartProduct.price, specifier: "%.2f")")
                        .bold()
                    
                    Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
            }
            .padding(.vertical)
            
            Spacer()
            
            // Quantity adjustment buttons
            HStack(spacing: 10) {
                Button {
                    viewModel.increaseQuantity(cart: cartProduct, change: .increase)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                }
                
                
                Text("\(cartProduct.quantity)")
                    .font(.headline)
                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                
                Button {
                    if cartProduct.quantity > 1 {
                        viewModel.increaseQuantity(cart: cartProduct, change: .decrease)
                    } else {
                        viewModel.removeCartItem(cart: cartProduct)
                    }
                } label: {
                    Image(systemName: cartProduct.quantity > 1 ? "minus.circle.fill" : "trash.circle.fill")
                        .font(.system(size: 24))
                }
                .buttonStyle(.plain) // Prevent default button tap styling
                .contentShape(Rectangle()) // Ensures buttons only trigger on their shape
                
            }
            .foregroundStyle(themeManager.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2))
            .font(.system(size: 20))
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(themeManager.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
