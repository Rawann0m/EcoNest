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
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            NavigationStack {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        
                        // Custom top app bar with title
                        AppBar(viewModel: cartViewModel)
                        
                        // Search bar for filtering products
                        SearchView()
                        
                        // Auto-playing promotional image slider
                        ImageSliderView()
                        
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
                            LazyVGrid(columns: gridLayout, spacing: 15) {
                                ForEach(homeViewModel.filtered) { product in
                                    ProductCardView(product: product)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 45)
                        }
                    }
                }
            }
        }
        // Fetch product data when view appears
        .onAppear {
            homeViewModel.fetchProductData()
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
