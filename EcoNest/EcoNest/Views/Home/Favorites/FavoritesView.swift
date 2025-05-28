//
//  FavoritesView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI


/// Displays a list of plants that the user has marked as favorites.
///
/// `FavoritesView` enables browsing, deleting, and navigating to details of favorite plants.
/// It supports right-to-left layout for Arabic and uses a shared `ThemeManager` for styling.
///
/// The view listens for updates to the user's favorites and cleans up listeners on disappear.
struct FavoritesView: View {
    
    /// View model managing favorite plant logic.
    @StateObject var favoriteVM = FavoritesViewModel()
    
    /// Selected plant for navigation to its detail screen.
    @State private var selectedPlant: Plant?
    
    /// Theme manager to adjust styling (light/dark).
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Currently selected language for layout and labels.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Dismiss handler for the current view.
    @Environment(\.dismiss) var dismiss
    
    
    
    var body: some View {
        
        List {
            ForEach(favoriteVM.favoritePlants) { plant in
                Button {
                    selectedPlant = plant
                } label: {
                    FavoriteCard(plant: plant)
                        
                }
                .listRowSeparator(.hidden)
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        favoriteVM.removeFavoritePlant(plantId: plant.id ?? "")
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                
            }
            
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                CustomBackward(title: "Favorites".localized(using: currentLanguage), tapEvent: {dismiss()})
            }
        }
        .listStyle(.plain)
        .navigationDestination(item: $selectedPlant) { plant in
            PlantDetails(plantName: plant.name)
        }
        .onAppear {
            favoriteVM.fetchFavorites()
        }
        .onDisappear {
            favoriteVM.removeListeners()
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}

/// A visual card showing brief info about a favorite plant.
///
/// `FavoriteCard` presents the plant image, name, and a short description.
/// It dynamically adapts styling based on the app's dark/light theme and supports localization direction.
struct FavoriteCard: View {
    
    /// The plant data to display.
    let plant: Plant
    
    /// Theme manager used to adapt the style.
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Current language code for layout direction.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    
    var body: some View {
        HStack(spacing: 12) {
            if let url = URL(string: plant.image) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(plant.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            Image(systemName: currentLanguage == "ar" ? "chevron.left" : "chevron.right")
                .foregroundColor(.gray)
        }
        .foregroundStyle(themeManager.isDarkMode ? .white : .black)
        .padding()
        .background(themeManager.isDarkMode ? Color(.secondarySystemBackground) : Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
