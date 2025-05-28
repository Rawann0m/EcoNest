//
//  AllProductsView.swift
//  EcoNest
//
//  Created by Mac on 28/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A view that displays a list of all available products.
struct AllProductsView: View {
    let products: [Product]  // Array of products to display
    
    @Environment(\.dismiss) private var dismiss        // Used to dismiss the view
    @EnvironmentObject var themeManager: ThemeManager  // Used to observe current theme (light/dark mode)
    
    // Observes current language preference
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // MARK: - Product Cards List
                ForEach(products) { product in
                    NavigationLink {
                        ProductDetailsView(productId: product.id ?? "")
                    } label: {
                        ProductRowCard(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // MARK: - Custom Back Button
            ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                CustomBackward(title: "All Products".localized(using: currentLanguage)) {
                    dismiss()
                }
            }
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Reusable Product Card View
struct ProductRowCard: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Product Image
            if let url = URL(string: product.image ?? "") {
                WebImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // MARK: - Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "")
                    .font(.headline)
                    .lineLimit(2)
                Text("SAR \(product.price ?? 0.0, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
