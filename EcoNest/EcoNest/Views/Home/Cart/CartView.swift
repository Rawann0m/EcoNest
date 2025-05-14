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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationViewModel: LocationViewModel
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView()
            }
            // Show empty state if cart is empty
            else if viewModel.cartProducts.isEmpty {
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
                    .onDelete(perform: viewModel.removeFormCart)
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
                    NavigationLink(destination: ReviewView(viewModel: viewModel, currentLanguage: currentLanguage) .environmentObject(locationViewModel)) {
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
                .padding([.top, .bottom]) 
            }
        }
        .padding(.top)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CustomBackward(title: "MyCart".localized(using: currentLanguage), tapEvent: {dismiss()})
            }
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
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
