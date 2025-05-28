//
//  HomeView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

/// Main view representing the home screen of the app
struct HomeView: View {
    
    // MARK: - State Objects
    
    /// ViewModel for managing the user's cart
    @StateObject private var cartViewModel = CartViewModel()
    
    /// ViewModel for managing product data and search
    @StateObject private var homeViewModel = HomeViewModel()
    
    /// Controls the number of visible products in the grid
    @State private var visibleProductCount = 12
    
    /// Observes and stores the user's current language preference
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        
        ZStack(alignment: .top) {
            NavigationStack {
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        // MARK: - Top Bar
                        
                        // Custom App Bar with title and cart/favorite icons
                        AppBar(viewModel: cartViewModel)
                            .padding(.top)
                        
                        // Search bar for filtering product list
                        SearchView(viewModel: homeViewModel)
                        
                        // Image slider shown only when no search is active
                        if homeViewModel.search.isEmpty {
                            ImageSliderView(viewModel: homeViewModel)
                        }
                        
                        // Section title for products
                        HStack {
                            Text("Explore".localized(using: currentLanguage))
                                .font(.title)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Product Grid
                        
                        // Responsive grid layout using adaptive sizing
                        let gridLayout = [
                            GridItem(.adaptive(minimum: 150, maximum: 250), spacing: 20)
                        ]
                        
                        // Show loading indicator while products are being fetched
                        if homeViewModel.products.isEmpty {
                            ProgressView()
                        }
                        
                        // Show empty state if filtered results are empty
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
                        
                        // Show filtered product grid
                        else {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: gridLayout, spacing: 15) {
                                    ForEach(homeViewModel.filtered.prefix(visibleProductCount)) { product in
                                        ProductCardView(viewModel: homeViewModel, cartViewModel: cartViewModel, product: product)
                                    }
                                }

                                // "See More" button to load additional products
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
                            .padding(.bottom, 100) // Space for safe area and future bottom sheet
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        // MARK: - Search Filtering Behavior
        
        .onChange(of: homeViewModel.search) { oldValue, newValue in
            // Add debounce delay before filtering
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if newValue == homeViewModel.search && !newValue.isEmpty {
                    homeViewModel.filterData()
                }
            }
            
            // Reset filter if the search is cleared
            if newValue.isEmpty {
                withAnimation(.easeInOut(duration: 0.3)) {
                    homeViewModel.filtered = homeViewModel.products
                }
            }
        }
    }
}
