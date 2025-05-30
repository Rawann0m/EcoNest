//
//  CustomButton.swift
//  EcoNest
//
//  Created by Rawan on 06/05/2025.
//


import SwiftUI

/// A custom reusable button that adapts to the app's theme.
/// This button can be used anywhere throughout the app with a dynamic title, action, and corner radius.
struct CustomButton: View {
    
    // MARK: - Variables

    var title: String
    var action: () -> Void = {}
    var cornerRadius: CGFloat = 8
    @EnvironmentObject var themeManager: ThemeManager
    
    // To manage the colors of the background and text
    private var backgroundColor: Color {
        themeManager.isDarkMode ? Color("LightGreen") : Color("DarkGreen")
    }
    
    private var foregroundColor: Color {
        themeManager.isDarkMode ? Color("DarkGreen") : Color.white
    }
    
    //MARK: - View
    
    var body: some View {
        // The button
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
                .padding()
                .frame(width: 170)
        }
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .padding(.horizontal)
    }
}
