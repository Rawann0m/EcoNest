//
//  FavoritesView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 22/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoritesView: View {
    @StateObject var favoriteVM = FavoritesViewModel()
    @State private var selectedPlant: Plant?
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.dismiss) var dismiss
    
    
    
    var body: some View {
        
        List {
            ForEach(favoriteVM.favoritePlants) { plant in
                Button {
                    selectedPlant = plant
                } label: {
                    FavoriteCard(plant: plant)
                }
                
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
        
        
        
    }
}


struct FavoriteCard: View {
    let plant: Plant
    @EnvironmentObject var themeManager: ThemeManager
    
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
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .foregroundStyle(themeManager.isDarkMode ? .white : .black)
        .padding()
        .background(themeManager.isDarkMode ? Color(.secondarySystemBackground) : Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
