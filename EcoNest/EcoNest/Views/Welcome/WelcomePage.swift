//
//  WelcomePage.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//

import SwiftUI
struct WelcomePage: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isAnimating = false

    var body: some View {
        ZStack(alignment: .center) {
            // Background
            Color.black.ignoresSafeArea()
            Image("BG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(1)

            VStack(spacing: 20) {
                // Logo
                Image("EcoNestW")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 210)
                    .scaleEffect(isAnimating ? 1.0 : 0.8) // Scale from slightly smaller
                    .opacity(isAnimating ? 1.0 : 0.0)     // Fade in
                    .animation(.easeInOut(duration: 1.0), value: isAnimating) // Combined animation

                // Text
                VStack(spacing: 10) {
                    Text("Welcome to EcoNest")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Where every plant finds its perfect home.")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 10) // Slight initial offset
                .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating) // Fade and move up
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}
