//
//  PlantDetailBar.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 21/05/2025.
//

import SwiftUI

struct PlantDetailBar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var plantName: String
    @ObservedObject var viewModel: PlantDetailsViewModel
    var userId: String
    var plantId: String
    
    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text(plantName)
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
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
    }
}
