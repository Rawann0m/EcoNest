//
//  AllProductsView.swift
//  EcoNest
//
//  Created by Mac on 28/11/1446 AH.
//



// AllProductsView.swift
import SwiftUI
import SDWebImageSwiftUI

/// Displays a scrollable list of all products related to a specific plant or category.
///
/// `AllProductsView` shows each product using a concise row card layout,
/// and supports Arabic localization, dark/light themes, and navigation to detailed product views.
struct AllProductsView: View {
    
    /// Products to display in the list.
    let products: [Product]
    
    /// Dismiss handler for navigation control.
    @Environment(\.dismiss) private var dismiss
    
    /// Theme manager for styling consistency.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Current language for layout and labels.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
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
                  ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                      CustomBackward(title: "All Products".localized(using: currentLanguage), tapEvent: { dismiss() })
                  }

            }
              .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
              .navigationBarBackButtonHidden(true)
          }
      }





/// A horizontally-aligned row card showing a product's image, name, and price.
///
/// `ProductRowCard` uses SDWebImage to load images and adjusts layout responsively.
/// It's designed for use in product listing views like `AllProductsView`.
struct ProductRowCard: View {
    
    /// Product to display.
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
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
        .padding(.vertical , 6)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
