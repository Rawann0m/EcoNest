//
//  ImageSliderView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

// An auto-sliding image carousel view
struct ImageSliderView: View {
    
    // Tracks the currently displayed image index
    @State private var currentIndex = 0
    
    // List of image asset names to be shown in the slider
    var sliders: [String] = ["AfricanViolet", "Anthurium", "Begonia", "BirdParadise"]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            ZStack(alignment: .trailing) {
                
                // Display the current image based on index
                Image(sliders[currentIndex])
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .scaledToFit()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
            }
            
            // Dot indicators representing image count and current index
            HStack {
                
                ForEach(sliders.indices, id: \.self) { index in
                    Circle()
                        .fill(self.currentIndex == index ? Color("DarkGreen") : Color("LimeGreen"))
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
                if self.currentIndex + 1 == self.sliders.count {
                    self.currentIndex = 0 // Reset to first image
                } else {
                    self.currentIndex += 1 // Move to next image
                }
            }
        }
    }
}
