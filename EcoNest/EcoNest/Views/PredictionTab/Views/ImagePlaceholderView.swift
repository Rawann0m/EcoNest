//
//  ImagePlaceholderView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

/// A placeholder view displayed when no image is selected or available for prediction.
///
/// `ImagePlaceholderView` shows a neutral grey box with an informative icon and localized instruction text.
/// It dynamically adapts to dark mode via `ThemeManager` and supports Arabic layout direction.
struct ImagePlaceholderView: View {
    
    /// Stores and observes current language for localization.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Provides access to app-wide theming settings (light/dark).
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 300, height: 300)
            .overlay(
                VStack {
                    Image("noData")
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Text("SelectOrTakePhoto".localized(using: currentLanguage))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        .padding()
                }
            )
            .cornerRadius(15)
    }
}
