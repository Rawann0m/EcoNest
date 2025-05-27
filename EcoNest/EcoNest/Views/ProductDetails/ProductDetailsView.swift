//
//  ProductDetailsView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - Main view
struct ProductDetailsView: View {
    var productId: String
    @State private var selectedTab = 0
    @StateObject var productVM = ProductDetailsViewModel()
    @ObservedObject private var cartViewModel = CartViewModel()
    @ObservedObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    @AppStorage("AppleLanguages") var currentLanguage: String =
    Locale.current.language.languageCode?.identifier ?? "en"
    
    // MARK: Body
    var body: some View {
        Group {
            if let product = productVM.product {
                ScrollView {
                    VStack(spacing: 16) {
                        headerSection(product,selectedTab: $selectedTab)
                        priceAndCartSection(product)
                        descriptionSection(product)
                        sizesSection
                    }
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(edges: .top)
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
            } else if let error = productVM.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Loading...")
            }
        }.navigationBarBackButtonHidden(true)
        .onAppear { productVM.fetchProductDetails(productId: productId) }
        .onChange(of: productVM.selectedProductId) { newId in
            if let id = newId {
                productVM.fetchProductDetails(productId: id)
            }
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            AuthViewPage()
        }
    }
}

// MARK: - Private sub-views (pure refactors)

private extension ProductDetailsView {
    
    // Header with top shape, back bar, and hero image
    @ViewBuilder
    func headerSection(_ product: Product,selectedTab: Binding<Int>) -> some View {
        ZStack(alignment: .top) {
            CustomRoundedRectangle(topLeft: 0, topRight: 0,
                                   bottomLeft: 45, bottomRight: 45)
            .fill(Color("DarkGreen"))
            .frame(width: UIScreen.main.bounds.width, height: 350)
            .ignoresSafeArea(edges: .top)
            .shadow(radius: 5)
            
            TabView(selection: selectedTab) {
                if let imageUrl = product.image {
                    PlantImage(imageUrl: imageUrl)
                        .tag(0)
                }
                if let image3D = product.name?.capitalized.replacingOccurrences(of: " ", with: ""){
                    SceneKitLoaderView(modelName: image3D)
                        .tag(1)
                }

            }
            .frame(height: 400)
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
                ProductDetailBar(productName: "Product".localized(using: currentLanguage))
                    .foregroundColor(selectedTab.wrappedValue == 0 ? .white : Color("LimeGreen"))
            
            
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        
    }
    
    // Price text, currency icon, and add/remove button
    @ViewBuilder
    func priceAndCartSection(_ product: Product) -> some View {
        HStack {
            // Price and currency image
            HStack {
                Text("\(product.price ?? 0.0, specifier: "%.2f")")
                    .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                    .font(.system(size: 24, weight: .bold, design: .default))
                
                Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            
            Spacer()
            let isAddedToCart =
            cartViewModel.cartProducts.contains { $0.product.id == product.id }
            
            Button {
                if FirebaseManager.shared.isLoggedIn {
                    if isAddedToCart {
                        if let cartItem =
                            cartViewModel.cartProducts
                            .first(where: { $0.product.id == product.id }) {
                            cartViewModel.removeFormCart(cart: cartItem)
                        }
                    } else {
                        homeViewModel.addToCart(product: product)   // <-- SAME CALL
                    }
                } else {
                    AlertManager.shared.showAlert(title: "Alert".localized(using: currentLanguage), message: "YouNeedToLoginFirst".localized(using: currentLanguage))
                }
            } label: {
                HStack {
                    Text(isAddedToCart
                         ? "Remove".localized(using: currentLanguage)
                         : "Add".localized(using: currentLanguage))
                    .font(.headline)
                    .bold()
                    Image(systemName: isAddedToCart
                          ? "minus.circle.fill"
                          : "plus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                }
                .frame(width: 100)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(isAddedToCart ? Color("DarkGreen") : Color("LimeGreen"))
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .alert(isPresented: $alertManager.alertState.isPresented) {
                let st = alertManager.alertState
                
                return Alert(
                    title: Text(st.title),
                    message: Text(st.message),
                    primaryButton: .default(Text(st.primaryLabel)) {
                        if st.primaryLabel == "Login".localized(using: currentLanguage) {
                            navigateToLogin = true
                        }
                    },
                    secondaryButton: st.secondaryLabel != nil
                    ? .cancel(Text(st.secondaryLabel!))
                    : .cancel()
                )
            }
        }
        .padding()
    }
    
    // Name, description, and “Plant Sizes:” headline
    @ViewBuilder
    func descriptionSection(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(product.name ?? "Unknown")
                .font(.title)
                .bold()
            
            Text(
                (product.description ?? "No description")
                    .replacingOccurrences(of: ". ", with: ".\n")
            )
            .font(.body)
            .bold()
            .multilineTextAlignment(.leading)
            
            NavigationLink(destination: PlantDetails(plantName: product.name ?? "Unknown")) {
                Text("Learn More")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            Text("Plant Sizes:")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // Horizontal list of other sizes
    @ViewBuilder
    var sizesSection: some View {
        if !productVM.availableSizes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(productVM.availableSizes) { sizeProduct in
                        let isSelected = sizeProduct.id == productVM.product?.id
                        Button {
                            productVM.selectedProductId = sizeProduct.id
                        } label: {
                            ProductSizeCard(product: sizeProduct, isSelected: isSelected)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ProductDetailBar: View {
    let productName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text(productName)
                }
                
            }
            Spacer()
        }.font(.headline)
            .padding(.horizontal)
            .padding(.top, UIScreen.main.bounds.height > 667 ? 52 : 28)
    }
}

struct ProductSizeCard: View {
    let product: Product
    var isSelected: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let url = URL(string: product.image ?? "") {
                WebImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 120)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Text(product.size ?? "").font(.subheadline).bold()
                .frame(maxWidth: .infinity, alignment: .center)
            HStack {
                Text("\(product.price ?? 0.0, specifier: "%.2f")")
                    .foregroundStyle(themeManager.isDarkMode ? .white : .black)
                    .font(.system(size: 16, weight: .bold, design: .default))
                
                Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                    .resizable()
                    .frame(width: 15, height: 15)
            }.frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 140)
        .padding(8)
        .foregroundColor(themeManager.isDarkMode ? .white : Color("DarkGreen"))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    themeManager.isDarkMode
                    ? (isSelected ? Color("LightGreen") : Color.black.opacity(0.2))
                    : (isSelected ? Color("DarkGreen") : Color.white.opacity(0.2)),
                    lineWidth: 2
                )
        )
    }
}
