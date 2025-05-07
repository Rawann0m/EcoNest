//
//  MainTabView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 07/11/1446 AH.
//

import SwiftUI

/// The main view that contains a TabView and a custom bottom tab bar.
struct MainTabView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    // Tracks the currently selected tab index
    @State private var selectedTabIndex = 1
    
    var body: some View {
        
        TabView(selection: $selectedTabIndex) {
            Text("First Tab").tag(1)
            Text("Second Tab").tag(2)
            Text("Third Tab").tag(3)
            CommunityAndMessagesView().tag(4)
            SettingsView().tag(5)
        }
        .overlay(alignment: .bottom) {
            // Overlay the custom tab bar at the bottom of the screen
            CustomTabBar(selectedIndex: $selectedTabIndex)
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        .ignoresSafeArea()
    }
}
