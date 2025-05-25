//
//  ConfirmationAlert.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI

struct ConfirmationAlert: View {
    
    /// State variable to control the animation
    @State var animationCircle = false
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Allows dismissing the current view.
    @Environment(\.dismiss) var dismiss 
    
    /// Stores and observes the current language preference.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                
                // Confirmation checkmark with animated background circles
                ZStack {
                    AnimatedCircle(delay: 1.0, animate: animationCircle)
                    AnimatedCircle(delay: 1.5, animate: animationCircle)
                        .onAppear {
                            animationCircle.toggle()  // Start the animation when view appears
                        }
                    
                    // Checkmark icon in the center
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230, height: 230)
                        .foregroundStyle(Color("LimeGreen"))
                }
                
                // Success message
                Text("OrderSuccessfuly".localized(using: currentLanguage))
                    .foregroundStyle(themeManager.isDarkMode ? .white : Color("DarkGreen"))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                // Navigation button to go back to main view
                HStack(spacing: 20){
                    NavigationLink(destination: MainTabView()) {
                        Text("GoBack".localized(using: currentLanguage))
                            .foregroundStyle(.white)
                            .bold()
                            .frame(width: 160, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("LimeGreen"))
                            )
                    }
                }
            }
        }.navigationBarBackButtonHidden(true)
        // Set layout direction based on language
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}

/// Reusable animated circle view
struct AnimatedCircle: View {
    
    var delay: Double
    var animate: Bool
    
    var body: some View {
        
        Circle()
            .stroke(lineWidth: 2)
            .foregroundStyle(Color("LimeGreen"))
            .frame(width: 220, height: 220)
            .scaleEffect(animate ? 1.3 : 0.9)
            .opacity(animate ? 0 : 1)
            .animation(.easeInOut(duration: 2).delay(delay).repeatForever(autoreverses: true), value: animate)
    }
}

