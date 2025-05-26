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
    
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {

            VStack(alignment: .leading) {
                
                HStack {
                    // Title text
                    Text("Findyour".localized(using: currentLanguage))
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    // Favorite icon with navigation
                    IconNavigationLink(systemImageName: "heart", destination: FavoritesView())
                        .padding(.horizontal, 10)
                    // Cart icon with navigation
                    //IconNavigationLink(systemImageName: "cart", destination: CartView(cartViewModel: viewModel))
                    ZStack(alignment: .topTrailing) {
                        NavigationLink {
                            CartView(cartViewModel: viewModel)
                        } label: {
                            Image(systemName: "cart")
                                .foregroundStyle(.black)
                                .background {
                                    Circle()
                                        .fill(Color("LimeGreen"))
                                        .frame(width: 35, height: 35)
                                }
                        }
                        
                        if viewModel.cartProducts.count > 0 {
                            Text("\(viewModel.cartProducts.count)")
                                .font(.caption)
                                .foregroundStyle(themeManager.isDarkMode ? Color("DarkGreen") : .white)
                                .background {
                                    Circle()
                                        .fill(themeManager.isDarkMode ? .white : Color("DarkGreen"))
                                        .frame(width: 20, height: 20)
                                }
                                .offset(x: 4, y: -5)
                        }
                    }
                    
                }
                .font(.system(size: 20))
                
                // Subtitle text
                Text("Favoriteplants".localized(using: currentLanguage))
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color("LimeGreen"))
            }
            .padding(.horizontal, 16) 
        
    }
}

// MARK: - IconNavigationLink (Reusable Navigation Icon with Background)
struct IconNavigationLink<Destination: View>: View {
    
    // System image name
    let systemImageName: String
    
    // View to navigate to on tap
    let destination: Destination
    
    var body: some View {
        NavigationLink {
            destination // Destination view
        } label: {
            Image(systemName: systemImageName)
                .foregroundStyle(.black)
                .background {
                    Circle()
                        .fill(Color("LimeGreen"))
                        .frame(width: 35, height: 35)
                }
        }
    }
}
