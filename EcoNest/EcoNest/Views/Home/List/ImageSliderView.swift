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
            
            if viewModel.leastProducts.indices.contains(currentIndex) {
                
                TabView(selection: $currentIndex) {
                    ForEach(viewModel.leastProducts.indices, id: \.self) { index in
                        NavigationLink(destination: ProductDetailsView(productId: viewModel.leastProducts[index].id ?? "")) {
                            ZStack(alignment: .bottomLeading) {
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
                                    ProgressView()
                                        .frame(height: 180)
                                }
                                
                                // Overlayed Text at top left
                                Text(viewModel.leastProducts[index].name ?? "")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding([.bottom, .leading])
                            }
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(height: 220)
                
            }
            
        }
        .padding()
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
            if self.currentIndex + 1 == viewModel.leastProducts.count {
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
