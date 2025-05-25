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
    @State private var timer: Timer? = nil
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            
            ZStack(alignment: .trailing) {
                
                TabView(selection: $currentIndex) {
                    ForEach(viewModel.sliderImages.indices, id: \.self) { index in
                        
                        let sliderItem = viewModel.sliderImages[index]
                        
                        ZStack(alignment: .bottomLeading) {
                            WebImage(url: URL(string: sliderItem.image ?? "")) { image in
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
                        .tag(index)
                    }
                    
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(height: 220)
                
            }
        }
        .padding(.top)
        .padding(.horizontal, 16)
        .onAppear {
            
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Timer Control
    
    private func startTimer() {
        stopTimer() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if self.currentIndex + 1 == viewModel.sliderImages.count {
                self.currentIndex = 0
            } else {
                self.currentIndex += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


