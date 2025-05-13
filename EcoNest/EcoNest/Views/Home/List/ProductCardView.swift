//
//  ProductCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

// A reusable view that displays a product card for a product plant.
struct ProductCardView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    var product: Product
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        
        ZStack {
        
            ZStack(alignment: .bottomTrailing) {
                
                VStack(alignment: .leading) {
                    
                    // Product image with styling
                    //Image(product.image)
                    WebImage(url: URL(string: product.image))
                        .resizable()
                        .background(Color.gray.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                    
                    // Product name text
                    Text(product.name)
                        .font(.subheadline)
                        .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                        .padding(.vertical, 1)
                    
                    // Price and currency image
                    HStack {
                        Text("\(product.price, specifier: "%.2f")")
                            .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                            .bold()
                        
                        Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    
                }
                
                // Add-to-cart button
                Button(action: {
                    viewModel.addToCart(product: product)
                }, label: {
                    Image(systemName: product.isAddedToCart ? "checkmark.circle.fill" : "plus.circle.fill")
                        .resizable()
                        .foregroundStyle(product.isAddedToCart ? Color("LightGreen") : Color("LimeGreen"))
                        .frame(width: 35, height: 35)
                })
            }
        }
        .frame(width: 175, height: 230)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.3), lineWidth: 2)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
        )
    }
}

   
