//
//  OrderCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import SwiftUI

struct OrderCardView: View {
    
    var order: Order
    @ObservedObject var viewModel: OrderViewModel
    @State private var showCancelAlert = false
    var currentLanguage: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12){
            
            VStack {
                Text("Scheduled".localized(using: currentLanguage))
                Text(order.date.formattedAsOrderDate())
            }
            .padding()
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity)
            .background(Color("LimeGreen"))
                                    
            VStack(alignment: .leading, spacing: 8, content: {
                Text(String(format: "PlantO".localized(using: currentLanguage),
                            order.products.map { $0.name ?? "" }.joined(separator: ", ")))
                    .foregroundStyle(.primary)
                
                HStack {
                    
                    Text(String(format: "TotalO".localized(using: currentLanguage), String(format: "%.2f", order.total)))
                        .foregroundStyle(.primary)
                        .bold()
                    
                    Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
                if order.status == .awaitingPickup {
                    Button(action: {
                        showCancelAlert = true
                    }) {
                        Text("Cancel".localized(using: currentLanguage))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .alert("CancelOrder".localized(using: currentLanguage), isPresented: $showCancelAlert) {
                        Button("Yes".localized(using: currentLanguage), role: .destructive) {
                            viewModel.cancelOrders(order: order)
                        }
                        Button("No".localized(using: currentLanguage), role: .cancel) { }
                    } message: {
                        Text("CancelThisOrder".localized(using: currentLanguage))
                    }
                }

            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            
        }
        .padding(.trailing)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("LimeGreen"), lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

