//
//  HomeView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

/// Main view representing the home screen of the app
struct HomeView: View {
    
    // Stores and observes the current language preference
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    // State objects for managing cart and product data
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var visibleProductCount = 12

    var body: some View {
        
        ZStack(alignment: .top) {
            
            NavigationStack {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        
                        // Custom top app bar with title
                        AppBar(viewModel: cartViewModel)
                            .padding(.top, 14)
                        
                        // Search bar for filtering products
                        SearchView(viewModel: homeViewModel)
                        
                        // Auto-playing promotional image slider
                        if homeViewModel.search.isEmpty {
                            ImageSliderView(viewModel: homeViewModel)
                        }
                        
                        // Section title for product grid
                        HStack {
                            Text("Explore".localized(using: currentLanguage))
                                .font(.title)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        // Calculate number of columns based on screen width
                        // Use adaptive GridItem to ensure responsiveness on different screen sizes
                        let gridLayout = [
                            GridItem(.adaptive(minimum: 150, maximum: 250), spacing: 20)
                        ]
                        
                        if homeViewModel.products.isEmpty {
                            ProgressView()
                        }
                        
                        else if homeViewModel.filtered.isEmpty {
                            VStack {
                                Image("Search")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.gray)
                                
                                Text("NoProductsFound".localized(using: currentLanguage))
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        else {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: gridLayout, spacing: 15) {
                                    ForEach(homeViewModel.filtered.prefix(visibleProductCount)) { product in
                                        NavigationLink(destination: ProductDetailsView(productId: product.id ?? "")) {
                                            ProductCardView(viewModel: homeViewModel, cartViewModel: cartViewModel, product: product)
                                        }
                                    }
                                }

                                if visibleProductCount < homeViewModel.filtered.count {
                                    
                                    Text("SeeMore".localized(using: currentLanguage))
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(Color("LimeGreen"))
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            visibleProductCount += 12
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
        // Observe changes in the search term and filter products accordingly
        .onChange(of: homeViewModel.search) { oldValue, newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if newValue == homeViewModel.search && !newValue.isEmpty {
                    homeViewModel.filterData()
                }
            }
            
            // Reset filtered list if search is cleared
            if newValue.isEmpty {
                withAnimation(.easeInOut(duration: 0.3)) {
                    homeViewModel.filtered = homeViewModel.products
                }
            }
        }
    }
}
