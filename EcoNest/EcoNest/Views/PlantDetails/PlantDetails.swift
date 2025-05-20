//
//  PlantDetails.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct PlantDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let plantName: String
    
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
    }) {
        HStack {
            Image(systemName: "chevron.backward")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
            Text(plantName)
                .foregroundColor(.white)
        }
    }
    }
    
    var favBtn : some View {
        Button(action: {
            // Button Action
        }) {
            Image(systemName: "heart")
                .foregroundColor(.white)
        }
    }
    
    var body: some View {
        
        VStack {
            ZStack {
                CustomRoundedRectangle(topLeft: 0, topRight: 0, bottomLeft: 45, bottomRight: 45)
                    .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
                    .fill(Color("DarkGreen"))
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Image()
                    Text("Details for \(plantName)")
                        .font(.title)
                }
            }.navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        btnBack
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        favBtn
                    }
                }
        }
        
        
    }
}

#Preview {
    PlantDetails(plantName: "Rose")
}

