//
//  CartView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI

struct CartView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CartViewModel
    
    var body: some View {
            List {
                ForEach(viewModel.cartProducts) { cart in
                    CartProductRow(product: cart.product)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        
        .navigationTitle("My Cart")
        .padding(.top)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }) {
                    Image(systemName: "bag")
                        .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                }
            }
        }
        .onAppear {
            viewModel.loadCartFromDefaults()
        }
    }
}

