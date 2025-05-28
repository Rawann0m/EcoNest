//
//  CartView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI

/// A SwiftUI view that displays the user's cart items or an empty state if no items are added.
struct CartView: View {
    
    /// View model responsible for cart interactions.
    @ObservedObject var cartViewModel: CartViewModel
    
    /// View model responsible for handling location data.
    @EnvironmentObject private var locationViewModel: LocationViewModel
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Allows dismissing the current view.
    @Environment(\.dismiss) var dismiss
    
    /// Stores and observes the current language preference.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Binding var openCart: Bool
    var body: some View {
        
        NavigationStack {
            VStack{
            // Show loading indicator if data is being fetched
            if cartViewModel.isLoading {
                ProgressView()
            }
            
            // Show empty state if the cart has no products
            else if cartViewModel.cartProducts.isEmpty {
                
                VStack(spacing: 10) {
                    
                    // Cart image placeholder
                    Image("Cart")
                        .resizable()
                        .frame(width: 230, height: 230)
                    
                    // Localized text indicating the cart is empty
                    Text("YourCartEmpty".localized(using: currentLanguage))
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    // Localized instruction to add products
                    Text("AddProductsHere".localized(using: currentLanguage))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                .padding()
            }
            
            // Display cart items when the cart is not empty
            else {
                
                List {
                    ForEach(cartViewModel.cartProducts) { cart in
                        // Reusable row view for each cart item
                        CartProductRow(viewModel: cartViewModel, cartProduct: cart)
                            .listRowSeparator(.hidden) // Remove default separators
                    }
                    .onDelete(perform: cartViewModel.removeFormCart) // Enable swipe-to-delete
                }
                .listStyle(.plain)
                
                // Bottom section: total price and continue button
                HStack {
                    
                    // Left side: display total cart price
                    HStack {
                        
                        Text("\(cartViewModel.calculateTotal(), specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // Currency icon that adapts to theme mode
                        Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Right side: continue to review
                    NavigationLink(destination:
                        CheckoutView(viewModel: cartViewModel, currentLanguage: currentLanguage, openCart: $openCart)
                            .environmentObject(locationViewModel)
                    ) {
                        
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
            // Custom back button title with localized label
            ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                CustomBackward(title: "MyCart".localized(using: currentLanguage), tapEvent: { dismiss() })
            }
            
            // Navigation to order history (bag icon)
            ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarLeading : .navigationBarTrailing) {
                NavigationLink(destination: OrderView(currentLanguage: currentLanguage)) {
                    Image(systemName: "bag")
                        .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                }
            }
        }
        }
        // Adjust layout direction based on language (RTL for Arabic)
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        .navigationBarBackButtonHidden(true) // Hide default back button
    }
}
