//
//  ProductCardView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

// A reusable view that displays a product card for a product plant.
struct ProductCardView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: HomeViewModel
    @State private var showLoginAlert = false
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    @ObservedObject var cartViewModel: CartViewModel
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var processingProductID: String? = nil

    var product: Product
    
    var body: some View {
        
        ZStack {
        
            ZStack(alignment: .bottomTrailing) {
                
                VStack(alignment: .leading) {
                    
                    // Product image with styling
                    WebImage(url: URL(string: product.image ?? ""))
                        .resizable()
                        .background(Color.gray.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .cornerRadius(8)
                        
                    // Product name text
                    Text(product.name ?? "")
                        .font(.subheadline)
                        .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                        .padding(.vertical, 1)
                    
                    Text(product.size ?? "")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    
                    // Price and currency image
                    HStack {
                        Text("\(product.price ?? 0.0, specifier: "%.2f")")
                            .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                            .bold()
                        
                        Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    
                }
                
                let isAddedToCart = cartViewModel.cartProducts.contains(where: { $0.product.id == product.id })
                let isProcessing = processingProductID == product.id

                Button(action: {
                    guard !isProcessing else { return }
                    processingProductID = product.id

                    if FirebaseManager.shared.isLoggedIn {
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
                .disabled(isProcessing)
                .alert(isPresented: $alertManager.alertState.isPresented) {
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

   
