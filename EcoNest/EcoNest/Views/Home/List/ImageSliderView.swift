//
//  ImageSliderView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

// An auto-sliding image carousel view
struct ImageSliderView: View {
    
    // Tracks the currently displayed image index
    @State private var currentIndex = 0
    
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            ZStack(alignment: .trailing) {
                
                // Display the current image based on index
                if currentIndex < viewModel.sliderImages.count {
                    WebImage(url: URL(string: viewModel.sliderImages[currentIndex])) { image in
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
                        ProgressView()
                            .frame(height: 180)
                    }
                }
                
            }
            
            // Dot indicators representing image count and current index
            HStack {
                
                ForEach(viewModel.sliderImages.indices, id: \.self) { index in
                    Circle()
                        .fill(self.currentIndex == index ?  themeManager.isDarkMode ? Color("LightGreen") : Color("DarkGreen") : Color("LimeGreen"))
                        .frame(width: 12, height: 12)
                }
            }
            .padding()
        }
        .padding(.top)
        .padding(.horizontal, 16)
        
        // Automatically updates the image every 5 seconds
        .onAppear {
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                if self.currentIndex + 1 == viewModel.sliderImages.count {
                    self.currentIndex = 0 // Reset to first image
                } else {
                    self.currentIndex += 1 // Move to next image
                }
            }
        }
    }
}
