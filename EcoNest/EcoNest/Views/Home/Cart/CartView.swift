//
//  CartView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI

/// A SwiftUI view that displays the user's cart items or an empty state if no items are added.
struct CartView: View {
    
    /// Manages dark/light mode theming throughout the app.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// ViewModel that handles cart operations like fetching and updating cart data.
    @ObservedObject var viewModel: CartViewModel
    
    /// Stores and observes the current language preference (used for localization).
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        NavigationStack {
            // Show empty state if cart is empty
            if viewModel.cartProducts.isEmpty {
                VStack(spacing: 10) {
                    
                    // Display cart image
                    Image("Cart")
                        .resizable()
                        .frame(width: 230, height: 230)
                    
                    // Localized message when the cart is empty
                    Text("YourCartEmpty".localized(using: currentLanguage))
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    // Localized instruction to add products
                    Text("AddProductsHere".localized(using: currentLanguage))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                .padding()
            } else {
                // Display list of cart products when cart is not empty
                List {
                    ForEach(viewModel.cartProducts) { cart in
                        CartProductRow(cartProduct: cart)
                            .listRowSeparator(.hidden) // Hide separator for a cleaner look
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    // Left side: total price display
                    HStack {
                        // Show the calculated total
                        Text("\(viewModel.calculateTotal(), specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Display the currency icon
                        Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Right side: Continue button
                    Button(action: {
                        
                    }) {
                        // Localized button label
                        Text("Continue".localized(using: currentLanguage))
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("LimeGreen"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .padding(.top) 
            }
        }
        // Navigation title at the top of the screen
        .navigationTitle("MyCart".localized(using: currentLanguage))
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
        // Fetch cart data when view appears
        .onAppear {
            viewModel.fetchCartData()
        }
    }
}
