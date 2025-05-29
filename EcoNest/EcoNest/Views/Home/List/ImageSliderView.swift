//
//  ImageSliderView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// An auto-sliding image carousel view displaying the least products from the home view model.
struct ImageSliderView: View {
    
    /// View model providing the list of least products to display.
    @ObservedObject var viewModel: HomeViewModel
    
    /// Tracks the index of the currently displayed image.
    @State private var currentIndex = 0
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Timer to automatically advance the carousel.
    @State private var timer: Timer? = nil
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            
            // Ensure currentIndex is within valid range before showing the TabView
            if viewModel.leastProducts.indices.contains(currentIndex) {
                
                // A page-style TabView to allow swiping between product cards
                TabView(selection: $currentIndex) {
                    
                    ForEach(viewModel.leastProducts.indices, id: \.self) { index in
                        
                        // Each tab navigates to its corresponding product detail
                        NavigationLink(destination: ProductDetailsView(productId: viewModel.leastProducts[index].id ?? "")) {
                            
                            ZStack(alignment: .bottomLeading) {
                                
                                // Product image
                                WebImage(url: URL(string: viewModel.leastProducts[index].image ?? "")) { image in
                                    image
                                        .resizable()
                                        .frame(width: 180, height: 220)
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.gray.opacity(0.10), lineWidth: 1)
                                                .background(Color.gray.opacity(0.15).cornerRadius(15))
                                        )
                                } placeholder: {
                                    // Placeholder while loading image
                                    ProgressView()
                                        .frame(height: 180)
                                }
                                
                                // Product name
                                Text(viewModel.leastProducts[index].name ?? "")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        themeManager.isDarkMode
                                            ? Color.white.opacity(0.1)
                                            : Color.black.opacity(0.1)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding([.bottom, .leading])
                            }
                            .tag(index) // Tag each tab to sync with currentIndex
                        }
                    }
                }
                .tabViewStyle(.page) // Enable swipeable pagination
                .indexViewStyle(.page(backgroundDisplayMode: .interactive)) // Dots at the bottom
                .frame(height: 220) // Fixed height for the carousel
            }
        }
        .padding()
        .onAppear {
            startTimer() // Start auto-scrolling on appear
        }
        .onDisappear {
            stopTimer() // Stop timer when the view disappears
        }
    }
    
    // MARK: - Timer Control
    
    /// Starts or restarts the auto-slide timer, cycling every 5 seconds.
    private func startTimer() {
        
        stopTimer() // Ensure only one timer is active
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            
            // Advance to the next index or reset to 0
            if self.currentIndex + 1 == viewModel.leastProducts.count {
                self.currentIndex = 0
            } else {
                self.currentIndex += 1
            }
        }
    }
    
    /// Invalidates and clears the timer.
    private func stopTimer() {
        
        timer?.invalidate() // Stops the timer from firing in the future
        timer = nil // Sets the reference to nil to free memory
    }
}
