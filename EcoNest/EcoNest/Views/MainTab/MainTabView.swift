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
    /// Theme manager to apply dynamic styling based on light/dark mode.
    @EnvironmentObject var themeManager: ThemeManager
    // Tracks the currently selected tab index
    @State private var selectedTabIndex = 1
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTabIndex) {
                HomeView().tag(1).toolbar(.hidden, for: .tabBar)
                PlantsListView().tag(2).toolbar(.hidden, for: .tabBar)
                PredictionView().tag(3) .toolbar(.hidden, for: .tabBar)
                CommunityAndMessagesView().tag(4)
                SettingsView().tag(5).toolbar(.hidden, for: .tabBar)
            }
            .overlay(alignment: .bottom) {
                // Overlay the custom tab bar at the bottom of the screen
                CustomTabBar(selectedIndex: $selectedTabIndex)
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
            .ignoresSafeArea()
        }
        .id(themeManager.isDarkMode)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Set the badge count of the app icon to 0
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("Error setting badge: \(error)")
                }
            }
            
        }
    }
}
