//
//  PredictionResultView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct PredictionResultView: View {
    let image: UIImage
    let predictions: [(String, Float)]
    let currentLanguage: String
    let onShare: () -> Void
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .shadow(radius: 5)
                .frame(width: 360, height: 360)
            
            
            
            VStack {
                HStack {
                    Text("TopPredictions:".localized(using: currentLanguage))
                        .font(.title)
                        .padding()
                    Spacer()
                    
                    if FirebaseManager.shared.isLoggedIn {
                        Button(action: onShare) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(10)
                        }
                        .buttonStyle(.plain)
                    }
                    
                }.padding(.trailing)
                ForEach(predictions, id: \.0) { prediction in
                    NavigationLink(destination: PlantDetails(plantName: prediction.0)) {
                        HStack {
                            Text(prediction.0)
                                .font(.body)
                                .padding(.leading)
                            Spacer()
                            Text(String(format: "%.2f%%", prediction.1))
                                .font(.body)
                            Image(systemName: currentLanguage == "ar" ? "chevron.left" : "chevron.right")
                                .font(.subheadline)
                                .padding(.trailing)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }.foregroundColor(.primary)
                        .buttonStyle(.plain)                   // remove default blue tint
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.15))    // lightly raised pill
                        )
                        .padding(.init(top: 0, leading: 8, bottom: 8, trailing: 8))
                }
                
                
                
            }
            .cornerRadius(15)
        }.environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        
    }
}
