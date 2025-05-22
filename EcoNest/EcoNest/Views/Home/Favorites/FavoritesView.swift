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
    
    var body: some View {
        
        List {
            ForEach(favoriteVM.favoritePlants, id: \.self) { plant in
                if let plantId = plant.id {
                    Button {
                        selectedPlant = plant
                    } label: {
                        FavoriteCard(plant: plant)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            favoriteVM.removeFavoritePlant(plantId: plantId)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            
            
        }
        .listStyle(.plain)
        .navigationDestination(item: $selectedPlant) { plant in
            PlantDetails(plantName: plant.name)
        }
        .navigationTitle("Favorites")
        .onAppear {
            favoriteVM.fetchFavorites()
        }
        .onChange(of: favoriteVM.favoritePlants) { _ in
            print("🌱 Favorite plants updated.")
        }
        .onDisappear {
            favoriteVM.removeListeners()
        }
        
        
        
    }
}


struct FavoriteCard: View {
    let plant: Plant
    
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
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
