//
//  CartProductRow.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

struct CartProductRow: View {
    
    var product: Product
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            WebImage(url: URL(string: product.image))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(.gray.opacity(0.15))
                .frame(width: 70, height: 70)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(product.name)
                
                HStack {
                    Text("\(product.price, specifier: "%.2f")")
                        .bold()
                    
                    Image("RiyalB")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
            }
            .padding(.vertical)
            
            Spacer()
            
            HStack {
                Image(systemName: "plus.circle.fill")
                
                Text("\(product.quantity)")
                    .foregroundStyle(.black)
                
                Image(systemName: "minus.circle.fill")
                
            }
            .foregroundStyle(.black.opacity(0.2))
            .font(.system(size: 20))
            
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.black.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}
