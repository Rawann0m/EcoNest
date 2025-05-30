//
//  SplashView.swift
//  EcoNest
//
//  Created by Rawan on 06/05/2025.
//

import SwiftUI

/// A view that displays a splash animation with a welcome screen before transitioning to the main interface.
struct SplashView: View {
    // MARK: - Variables
    
    @State private var showWelcome = true
    @State private var animateOut = false
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - View
    
    var body: some View {
            Group {
                // If `showWelcome` is true, show the welcome page; otherwise, navigate to the main tab view.
                if showWelcome {
                    WelcomePage()
                        .opacity(animateOut ? 0 : 1)
                        .scaleEffect(animateOut ? 1.2 : 1.0)
                        .transition(.opacity)
                        .accessibilityIdentifier("Welcome")
                } else {
                    MainTabView()
                        .accessibilityIdentifier("MainTabView")
                }
            }
            .onAppear {
                // Delay splash screen for 2.5 seconds, then animate it out and transition to the main view.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        animateOut = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showWelcome = false 
                    }
                }
            }
    }
}
