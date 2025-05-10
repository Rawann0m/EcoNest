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
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            // Product image loaded from a URL using SDWebImageSwiftUI
            WebImage(url: URL(string: cartProduct.product.image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(.gray.opacity(0.15))
                .frame(width: 70, height: 70)
                .cornerRadius(8)
            
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
            HStack {
                Image(systemName: "plus.circle.fill")
                
                Text("\(cartProduct.quantity)")
                    .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                
                Image(systemName: "minus.circle.fill")
                
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
