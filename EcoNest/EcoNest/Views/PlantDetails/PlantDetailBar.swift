//
//  PlantDetailBar.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 21/05/2025.
//

import SwiftUI

/// A customizable navigation bar for the plant detail screen.
///
/// `PlantDetailBar` provides a back button that adapts to the current language direction (LTR/RTL),
/// displays the plant's name, and allows logged-in users to favorite/unfavorite the plant.
/// It reacts to changes in the `PlantDetailsViewModel`.
///
/// This view is typically placed at the top of a detail screen to offer intuitive navigation and interaction.
///
/// - Requires: A valid `PlantDetailsViewModel` and appropriate `userId` and `plantId`.
struct PlantDetailBar: View {
    
    /// Environment variable to manage view dismissal.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    /// Stores the current language code for layout and symbol direction.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// The localized name of the plant being viewed.
    var plantName: String
    
    /// View model managing the plant's detail state, including favorite status.
    @ObservedObject var viewModel: PlantDetailsViewModel
    
    /// The identifier of the current user.
    var userId: String
    
    /// The identifier of the current plant.
    var plantId: String
    
    var body: some View {
        HStack {
            
            // Back button with language-aware icon direction
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: currentLanguage == "ar" ? "chevron.right" : "chevron.left")
                    Text(plantName)
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            
            // Favorite button visible only when user is logged in
            if FirebaseManager.shared.isLoggedIn {
                Button(action: {
                    viewModel.toggleFavorite(userId: userId, plantId: plantId)
                    
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(viewModel.isFavorite ? Color("DarkGreen") : Color("DarkGreenLight"))
                        .frame(width: 35, height: 35)
                        .background(Circle().fill(Color.white))
                }
                .foregroundColor(.white)
            }
            
        }.font(.headline)
            .padding(.horizontal)
            .padding(.top, UIScreen.main.bounds.height > 667 ? 52 : 28)
            .onAppear {
                if FirebaseManager.shared.isLoggedIn {
                    viewModel.checkFavoriteStatus(userId: userId, plantId: plantId)
                }
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
