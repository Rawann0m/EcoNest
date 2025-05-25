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
    var body: some View {

            VStack(alignment: .leading) {
                
                HStack {
                    // Title text
                    Text("Findyour".localized(using: currentLanguage))
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    // Favorite icon with navigation
                    IconNavigationLink(systemImageName: "heart", destination: Text("Favorite"))
                        .padding(.horizontal, 10)
                    // Cart icon with navigation
                    IconNavigationLink(systemImageName: "cart", destination: CartView(cartViewModel: viewModel))

                    
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
