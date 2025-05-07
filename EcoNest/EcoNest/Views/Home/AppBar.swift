//
//  AppBar.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

// MARK: - AppBar (Top Section with Title and Icons)
struct AppBar: View {
    var body: some View {

            VStack(alignment: .leading) {
                
                HStack {
                    // Title text
                    Text("Find your")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    // Favorite icon with navigation
                    IconNavigationLink(systemImageName: "heart", destination: Text("Favorite"))
                    
                    // Cart icon with navigation
                    IconNavigationLink(systemImageName: "cart", destination: Text("Cart"))
                }
                .font(.system(size: 25))
                
                // Subtitle text
                Text("Favorite plants")
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
                    Rectangle()
                        .fill(Color("LimeGreen"))
                        .frame(width: 35, height: 35)
                        .cornerRadius(8)
                }
        }
    }
}
