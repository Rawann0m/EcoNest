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
            
            Button(action: {
                // Button Action
            }) {
                Image(systemName: "heart")
                
            }
            .foregroundColor(.white)
            
        }.font(.headline)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}
