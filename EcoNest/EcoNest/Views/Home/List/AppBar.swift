//
//  AppBar.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

/// A customizable top app bar displaying the title, localized greeting, and icon buttons for favorites and cart.
struct AppBar: View {
    
    /// View model responsible for cart interactions.
    @ObservedObject var viewModel: CartViewModel
    
    /// Controls navigation to the login screen.
    @State private var navigateToLogin = false
    
    /// Controls the display of a login-required alert.
    @State private var showLoginAlert = false
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Stores and observes the current language preference.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            // Top row with greeting and icon buttons
            HStack {
                // Main greeting text
                Text("Findyour".localized(using: currentLanguage))
                    .font(.largeTitle.bold())
                
                Spacer()
                
                // Favorites icon
                IconNavigationLink (
                    systemImageName: "heart",
                    destination: FavoritesView(),
                    currentLanguage: currentLanguage,
                    showLoginAlert: $showLoginAlert
                )
                .padding(.horizontal, 10)

                // Cart icon with item count badge
                ZStack(alignment: .topTrailing) {
                    IconNavigationLink (
                        systemImageName: "cart",
                        destination: CartView(cartViewModel: viewModel),
                        currentLanguage: currentLanguage,
                        showLoginAlert: $showLoginAlert
                    )
                    
                    // Cart item count badge
                    if viewModel.cartProducts.count > 0 {
                        Text("\(viewModel.cartProducts.count)")
                            .font(.caption2)
                            .foregroundStyle(themeManager.isDarkMode ? Color("DarkGreen") : .white)
                            .background {
                                Circle()
                                    .fill(themeManager.isDarkMode ? .white : Color("DarkGreen"))
                                    .frame(width: 20, height: 20)
                            }
                            .offset(x: 5, y: -4) // Position badge over the cart icon
                    }
                }
            }
            .font(.system(size: 20))
            
            // Subheading text below app bar
            Text("Favoriteplants".localized(using: currentLanguage))
                .font(.largeTitle.bold())
                .foregroundStyle(Color("LimeGreen"))
        }
        .padding(.horizontal, 16)
        
        // Login alert when unauthenticated user taps an icon
        .alert("Alert".localized(using: currentLanguage), isPresented: $showLoginAlert) {
            Button("Login".localized(using: currentLanguage)) {
                navigateToLogin = true
            }
            Button("Cancel".localized(using: currentLanguage), role: .cancel) {}
        } message: {
            Text("Youneedtologinfirst!".localized(using: currentLanguage))
        }
        
        // Full-screen login view presentation
        .fullScreenCover(isPresented: $navigateToLogin) {
            AuthViewPage()
        }
    }
}


/// A reusable icon view that acts as either a NavigationLink (if logged in) or a Button (if not), showing a login alert.
struct IconNavigationLink<Destination: View>: View {
    
    /// SF Symbol name for the icon.
    let systemImageName: String
    
    /// The destination view to navigate to when logged in.
    let destination: Destination
    
    /// The current language code used for localization.
    var currentLanguage: String
    
    /// Binding to control the login alert display from parent view.
    @Binding var showLoginAlert: Bool

    var body: some View {
        Group {
            if FirebaseManager.shared.isLoggedIn {
                // Logged in: show navigation link to the destination view
                NavigationLink {
                    destination
                } label: {
                    iconView
                }
            } else {
                // Not logged in: show button that triggers the login alert
                Button {
                    showLoginAlert = true
                } label: {
                    iconView
                }
            }
        }
    }

    /// The styled icon inside a circle background.
    var iconView: some View {
        Image(systemName: systemImageName)
            .foregroundStyle(.black)
            .background {
                Circle()
                    .fill(Color("LimeGreen"))
                    .frame(width: 35, height: 35)
            }
    }
}
