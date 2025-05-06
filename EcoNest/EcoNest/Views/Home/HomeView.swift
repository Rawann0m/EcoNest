//
//  HomeView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        ZStack(alignment: .top) {
            
            NavigationStack {
                
                VStack {
                    // Custom app bar at the top of the screen
                    AppBar()
                    SearchView()
                    
                    Spacer() // Pushes content to the top
                }
            }
        }
        .padding(16) // Overall screen padding
    }
}

