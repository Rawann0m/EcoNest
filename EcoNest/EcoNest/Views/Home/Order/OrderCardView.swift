//
//  OrderCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import SwiftUI

struct OrderCardView: View {
    
    var order: Order
    
    var body: some View {
        HStack(spacing: 12){
            
            VStack {
                Text("Scheduled :")
                Text(order.date.formattedAsOrderDate())
            }
            .padding()
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity)
            .background(Color("LimeGreen"))
                                    
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Plant: \(order.products.map { $0.name ?? "" }.joined(separator: ", "))")
                    .foregroundStyle(.primary)
                
                HStack {
                    Text("Total: \(order.total, specifier: "%.2f")")
                        .foregroundStyle(.primary)
                        .bold()
                    
                    Image("RiyalB")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
                Text("Cancel")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            
        }
        .padding(.trailing)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("LimeGreen"), lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

