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
    
    // Animation state for the loading spinner
    @State private var degree: Int = 270
    @State private var spinnerLength = 0.6
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            NavigationStack {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        
                        // Custom top app bar with title
                        AppBar(viewModel: cartViewModel)
                        
                        // Search bar for filtering products
                        SearchView(viewModel: homeViewModel)
                        
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
                        let screenWidth = UIScreen.main.bounds.width
                        let columns = max(Int(screenWidth / 200), 1)
                        let gridLayout = Array(repeating: GridItem(.flexible(), spacing: 20), count: columns)
                        
                        // Loading state spinner while products are being fetched
                        if homeViewModel.products.isEmpty {
                            Circle()
                                .trim(from: 0.0, to: spinnerLength)
                                .stroke(.blue, lineWidth: 5)
                                .frame(width: 60, height: 60)
                                .rotationEffect(Angle(degrees: Double(degree)))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: degree)
                                .onAppear {
                                    // Animate spinner stroke and rotation
                                    withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: true)) {
                                        spinnerLength = 1
                                    }
                                    degree = 270 + 360
                                }
                        }
                        
                        // No results found placeholder after filtering
                        else if homeViewModel.filtered.isEmpty {
                            VStack {
                                Image("Search")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 220, height: 220)
                                    .foregroundColor(.gray)
                                
                                Text("NoProductsFound".localized(using: currentLanguage))
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        // Display filtered product cards in a responsive grid
                        else {
                            LazyVGrid(columns: gridLayout, spacing: 15) {
                                ForEach(homeViewModel.filtered) { product in
                                    ProductCardView(product: product, viewModel: cartViewModel)
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
            homeViewModel.fetchData()
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
