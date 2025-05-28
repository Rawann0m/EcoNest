//
//  AppBar.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

// MARK: - AppBar (Top Section with Title and Icons)
struct AppBar: View {
    
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @ObservedObject var viewModel: CartViewModel
    @State private var navigateToLogin = false
    @State private var showLoginAlert = false
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Findyour".localized(using: currentLanguage))
                    .font(.largeTitle.bold())
                
                Spacer()
                
                IconNavigationLink (
                    systemImageName: "heart",
                    destination: FavoritesView(),
                    currentLanguage: currentLanguage,
                    showLoginAlert: $showLoginAlert
                )
                .padding(.horizontal, 10)

                ZStack(alignment: .topTrailing) {
                    IconNavigationLink (
                        systemImageName: "cart",
                        destination: CartView(cartViewModel: viewModel),
                        currentLanguage: currentLanguage,
                        showLoginAlert: $showLoginAlert
                    )
                    
                    if viewModel.cartProducts.count > 0 {
                        Text("\(viewModel.cartProducts.count)")
                            .font(.caption2)
                            .foregroundStyle(themeManager.isDarkMode ? Color("DarkGreen") : .white)
                            .background {
                                Circle()
                                    .fill(themeManager.isDarkMode ? .white : Color("DarkGreen"))
                                    .frame(width: 20, height: 20)
                            }
                            .offset(x: 5, y: -4)
                    }
                }
            }
            .font(.system(size: 20))
            
            Text("Favoriteplants".localized(using: currentLanguage))
                .font(.largeTitle.bold())
                .foregroundStyle(Color("LimeGreen"))
        }
        .padding(.horizontal, 16)
        .alert("Alert".localized(using: currentLanguage), isPresented: $showLoginAlert) {
            Button("Login".localized(using: currentLanguage)) {
                navigateToLogin = true
            }
            Button("Cancel".localized(using: currentLanguage), role: .cancel) {}
        } message: {
            Text("Youneedtologinfirst!".localized(using: currentLanguage))
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            AuthViewPage()
        }
    }
}


struct IconNavigationLink<Destination: View>: View {
    
    let systemImageName: String
    let destination: Destination
    var currentLanguage: String
    @Binding var showLoginAlert: Bool

    var body: some View {
        Group {
            if FirebaseManager.shared.isLoggedIn {
                NavigationLink {
                    destination
                } label: {
                    iconView
                }
            } else {
                Button {
                    showLoginAlert = true
                } label: {
                    iconView
                }
            }
        }
    }

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
