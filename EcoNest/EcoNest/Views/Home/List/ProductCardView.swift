//
//  ProductCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

/// A reusable view that displays a product card for a plant product, including image, details, and add-to-cart functionality.
struct ProductCardView: View {
    
    /// Home view model for accessing product list and cart interaction.
    @ObservedObject var viewModel: HomeViewModel
    
    /// Cart view model for managing cart items.
    @ObservedObject var cartViewModel: CartViewModel
    
    /// Shared alert manager for triggering login-required alerts.
    @StateObject var alertManager = AlertManager.shared
    
    /// Controls display of the login-required alert.
    @State private var showLoginAlert = false
    
    /// Controls full screen login navigation.
    @State private var navigateToLogin = false
    
    /// Tracks whether the current product is being processed (prevents rapid taps).
    @State private var processingProductID: String? = nil
    
    /// Theme manager to support dark/light styling.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Current language setting for localization.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// The product to display in the card.
    var product: Product
    
    var body: some View {
        
        ZStack {
            
            ZStack(alignment: .bottomTrailing) {
                
                // Navigation link wrapping the entire product card
                NavigationLink(destination: ProductDetailsView(productId: product.id ?? "")) {
                    
                    VStack(alignment: .leading) {
                        
                        // Product image
                        WebImage(url: URL(string: product.image ?? ""))
                            .resizable()
                            .background(Color.gray.opacity(0.15))
                            .frame(width: 150, height: 150)
                            .cornerRadius(8)
                        
                        // Product name
                        Text(product.name ?? "")
                            .font(.subheadline)
                            .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                            .padding(.vertical, 1)
                        

                        // Product size
                        Text(product.size ?? "")
                            .foregroundStyle(.gray)
                            .font(.caption)
                        
                        // Product price and currency icon
                        HStack {
                            Text("\(product.price ?? 0.0, specifier: "%.2f")")
                                .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                                .bold()
                            
                            Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                    }
                }
                
                // MARK: - Add/Remove from Cart Button
                
                let isAddedToCart = cartViewModel.cartProducts.contains(where: { $0.product.id == product.id })
                let isProcessing = processingProductID == product.id
                
                Button(action: {
                    
                    guard !isProcessing else { return }
                    
                    processingProductID = product.id
                    
                    if FirebaseManager.shared.isLoggedIn {
                        
                        // Toggle cart state
                        if isAddedToCart {
                            if let cartItem = cartViewModel.cartProducts.first(where: { $0.product.id == product.id }) {
                                cartViewModel.removeFormCart(cart: cartItem)
                            }
                        } else {
                            viewModel.addToCart(product: product)
                        }
                        
                        // Reset processing state after Firestore update (can be improved using callback)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            processingProductID = nil
                        }
                    } else {
                        // Show login-required alert
                        AlertManager.shared.showAlert(
                            title: "Alert".localized(using: currentLanguage),
                            message: "YouNeedToLoginFirst".localized(using: currentLanguage)
                        )
                        processingProductID = nil
                    }
                }, label: {
                    
                    Image(systemName: isAddedToCart ? "minus.circle.fill" : "plus.circle.fill")
                        .resizable()
                        .foregroundStyle(
                            isAddedToCart
                                ? themeManager.isDarkMode ? .white.opacity(0.15) : .black.opacity(0.15)
                                : Color("LimeGreen")
                        )
                        .frame(width: 35, height: 35)
                })
                .disabled(isProcessing) // Prevent multiple taps
                .alert(isPresented: $alertManager.alertState.isPresented) {
                    // Alert shown when user is not logged in
                    Alert(
                        title: Text(alertManager.alertState.title),
                        message: Text(alertManager.alertState.message),
                        primaryButton: .default(Text("Login".localized(using: currentLanguage))) {
                            navigateToLogin = true
                        },
                        secondaryButton: .cancel(Text("Cancel".localized(using: currentLanguage)))
                    )
                }
            }
        }
        .frame(width: 175, height: 260)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.3), lineWidth: 2)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
        )
        .fullScreenCover(isPresented: $navigateToLogin) {
            AuthViewPage()
        }
    }
}

