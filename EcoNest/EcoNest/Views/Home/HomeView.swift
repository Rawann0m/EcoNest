//
//  HomeView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

/// Main view representing the home screen of the app
struct HomeView: View {
    var body: some View {
        
        ZStack(alignment: .top) {
            
            NavigationStack {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        
                        // Custom top app bar
                        AppBar()
                        
                        // Custom reusable search bar
                        SearchView()
                        
                        // Auto-playing image slider
                        ImageSliderView()
                        
                        // Header text for the grid section
                        HStack {
                            Text("Explore")
                                .font(.title)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        
                        // Dynamically calculates how many columns fit on screen
                        let screenWidth = UIScreen.main.bounds.width
                        let columns = max(Int(screenWidth / 200), 1)
                        
                        // Builds a responsive grid layout with spacing
                        let gridLayout = Array(repeating: GridItem(.flexible(), spacing: 20), count: columns)
                        
                        // Lazy-loading vertical grid for product cards
                        LazyVGrid(columns: gridLayout, spacing: 15) {
                            // Dummy loop to render 10 product cards
                            ForEach(1...10, id: \.self) { user in
                                ProductCardView()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)     
                    }
                }
            }
        }
    }
}
