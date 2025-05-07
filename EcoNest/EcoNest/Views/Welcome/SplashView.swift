//
//  SplashView.swift
//  EcoNest
//
//  Created by Rawan on 06/05/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var showWelcome = true
    @State private var animateOut = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                if showWelcome {
                    WelcomePage()
                        .opacity(animateOut ? 0 : 1)
                        .scaleEffect(animateOut ? 1.2 : 1.0)
                        .transition(.opacity)
                } else {
                    MainTabView()
                }
            }
            .onAppear {
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
}
