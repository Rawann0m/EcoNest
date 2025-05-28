//
//  ImagePlaceholderView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct ImagePlaceholderView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack {
            Image("Plant")
                .resizable()
                .scaledToFit()
                .padding()
            Text("SelectOrTakePhoto".localized(using: currentLanguage))
                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                .padding()
        }
    }
}
