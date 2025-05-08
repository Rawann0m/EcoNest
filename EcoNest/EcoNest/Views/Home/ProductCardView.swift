//
//  ProductCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI

// A reusable view that displays a product card for a product plant.
struct ProductCardView: View {
    var body: some View {
        
        ZStack {
        
            ZStack(alignment: .bottomTrailing) {
                
                VStack(alignment: .leading) {
                    
                    // Product image with styling
                    Image("AfricanViolet")
                        .resizable()
                        .background(Color.gray.opacity(0.15))
                        .frame(width: 160, height: 150)
                        .cornerRadius(8)
                    
                    // Product name text
                    Text("African Violet")
                        .font(.subheadline)
                        .foregroundStyle(.black)
                        .padding(.vertical, 1)
                    
                    // Price and currency image
                    HStack {
                        Text("300.00")
                            .foregroundStyle(.black)
                            .bold()
                        
                        Image("RiyalB")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                }
                
                // Add-to-cart button
                Button(action: {
                    
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundStyle(Color("DarkGreen"))
                        .frame(width: 35, height: 35)
                })
            }
        }
        .frame(width: 180, height: 230)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 2)
        )
    }
}
