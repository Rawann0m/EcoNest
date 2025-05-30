//
//  OrderCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import SwiftUI

/// A SwiftUI view that displays an individual order card with scheduling, product summary, total amount, and cancel option.
struct OrderCardView: View {
    
    /// View model responsible for handling order-related actions.
    @ObservedObject var orderViewModel: OrderViewModel
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showCancelAlert = false

    /// The order data to display in this card.
    var order: Order
    
    /// The current language code used for localization.
    var currentLanguage: String
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            // MARK: - Scheduled date section
            VStack {
                
                Text("Scheduled".localized(using: currentLanguage)) // "Scheduled" title localized
                
                Text(order.date.formattedDate()) // Formatted order date
            }
            .padding()
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxHeight: .infinity)
            .background(Color("LimeGreen"))
            
            // MARK: - Order details section
            VStack(alignment: .leading, spacing: 8) {
                
                // Product names summary
                Text(String(format: "PlantO".localized(using: currentLanguage),
                            order.products.map { $0.name ?? "" }.joined(separator: ", ")))
                    .foregroundStyle(.primary)
                
                // Total cost and currency image
                HStack {
                    Text(String(format: "TotalO".localized(using: currentLanguage),
                                String(format: "%.2f", order.total)))
                        .foregroundStyle(.primary)
                        .bold()
                    
                    Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
                // Cancel button appears only if status is "awaitingPickup"
                if order.status == .awaitingPickup {
                    Button(action: {
                        showCancelAlert = true
                    }) {
                        Text("Cancel".localized(using: currentLanguage))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .alert("CancelOrder".localized(using: currentLanguage), isPresented: $showCancelAlert) {
                        
                        // Confirm cancellation
                        Button("Yes".localized(using: currentLanguage), role: .destructive) {
                            orderViewModel.cancelOrders(order: order)
                        }
                        
                        // Dismiss alert
                        Button("No".localized(using: currentLanguage), role: .cancel) { }
                    } message: {
                        Text("CancelThisOrder".localized(using: currentLanguage))
                    }
                }
            }
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
