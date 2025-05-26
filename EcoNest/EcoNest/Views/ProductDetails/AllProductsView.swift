//
//  AllProductsView.swift
//  EcoNest
//
//  Created by Mac on 28/11/1446 AH.
//



// AllProductsView.swift
import SwiftUI
import SDWebImageSwiftUI

struct AllProductsView: View {
    let products: [Product]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
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






struct ProductRowCard: View {
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
