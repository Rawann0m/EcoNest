//
//  PlantDetails.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

/// Displays detailed information about a selected plant, including image, description, water/light stats, and recommended products.
///
/// This view initializes a `PlantDetailsViewModel` based on the passed `plantName`,
/// fetches plant-specific data, and presents interactive and visual content to the user.
/// It supports Arabic localization and user-specific favorite tracking when authenticated.
struct PlantDetails: View {
    
    /// The name of the selected plant.
    @State var plantName: String
    
    /// View model managing plant data and interaction logic.
    @StateObject var plantDetailsVM : PlantDetailsViewModel
    
    /// Reference value for water/light usage indicators.
    @State var outOf: Double = 100
    
    /// Currently selected language for localization and layout direction.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    
    /// Initializes the view and its stateful view model.
    init(plantName: String) {
        self.plantName = plantName
        _plantDetailsVM = StateObject(wrappedValue: PlantDetailsViewModel(PlantName: plantName))
        
    }
    
    /// Firebase authenticated user's ID.
    let userId = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16){
                ZStack(alignment: .top) {
                    
                    // Background container
                    CustomRoundedRectangle(topLeft: 0, topRight: 0, bottomLeft: 45, bottomRight: 45)
                        .fill(Color("DarkGreen"))
                        .frame(width: UIScreen.main.bounds.width, height: 350)
                        .ignoresSafeArea(edges: .top)
                        .shadow(radius: 5)
                    
                    
                    // Top navigation and action bar
                    PlantDetailBar(
                        plantName: "Details".localized(using: currentLanguage),
                        viewModel: plantDetailsVM,
                        userId: userId,
                        plantId: plantDetailsVM.plant?.id ?? ""
                    )
                    
                    
                    // Display plant image if available
                    if let imageUrl = plantDetailsVM.plant?.image {
                        PlantImage(imageUrl: imageUrl)
                    }
                    
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let plant = plantDetailsVM.plant {
                        Text("\(String(describing: plant.name)):")
                            .font(.title)
                            .bold()
                    }
                    
                    if let desc = plantDetailsVM.plant?.description {
                        Text(desc)
                            .font(.title3)
                        
                    }
                }.padding(.horizontal)
                
                // Display water and light usage indicators
                HStack {
                    ShapeView(usedWaterAmount: CGFloat(plantDetailsVM.waterLevel ?? 0.0), maxWaterAmount: CGFloat(outOf), color: Color("LimeGreen").opacity(0.4), icon: "drop.fill")
                    
                    ShapeView(usedWaterAmount: CGFloat(plantDetailsVM.lightLevel ?? 0.0), maxWaterAmount: CGFloat(outOf), color: Color("LimeGreen").opacity(0.4), icon: "sun.max.fill")
                }
                
                
                // Show recommended products if available
                if !plantDetailsVM.products.isEmpty {
                    RecommendedProductsSection(products: plantDetailsVM.products)
                }
                
                
            }
            
        }
        .onChange(of: plantDetailsVM.plant?.id) { newPlantId in
            if let id = newPlantId {
                if FirebaseManager.shared.isLoggedIn {
                    plantDetailsVM.checkFavoriteStatus(userId: userId, plantId: id)
                }
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
    
}

/// A horizontally scrolling list of recommended products for a plant.
struct RecommendedProductsSection: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    /// Products to be displayed.
    let products: [Product]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("RecommendedProducts:".localized(using: currentLanguage))
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllProductsView(products: products)) {
                    Text("SeeAll".localized(using: currentLanguage))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(products) { product in
                        NavigationLink {
                            ProductDetailsView(productId: product.id ?? "")
                        } label: {
                            ProductCard(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }.environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}

/// A SwiftUI view for displaying a plant's image using SDWebImage.
struct PlantImage: View {
    let imageUrl: String
    
    var body: some View {
        if let url = URL(string: imageUrl) {
            WebImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.top, 100)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            EmptyView()
        }
    }
}

/// A compact card view representing a product with image, name, and price.
struct ProductCard: View {
    let product: Product
    
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
            Text(product.name ?? "").font(.subheadline).bold()
                .frame(maxWidth: .infinity, alignment: .center)
            Text("SAR \(product.price ?? 0.0, specifier: "%.2f")")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 140)
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
