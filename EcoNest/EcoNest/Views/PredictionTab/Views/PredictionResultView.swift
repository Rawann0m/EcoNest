//
//  PredictionResultView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI


/// Displays a prediction result image alongside top plant type predictions.
///
/// `PredictionResultView` shows a selected/captured image and a list of
/// predicted plant labels with confidence percentages.
/// It supports localization and layout direction based on language settings,
/// and offers share and navigation capabilities.
struct PredictionResultView: View {
    
    /// The image on which predictions were made.
    let image: UIImage
    
    /// A list of (label, confidence) prediction results.
    let predictions: [(String, Float)]
    
    /// Current language code for text and layout.
    let currentLanguage: String
    
    /// Triggered when the share button is tapped.
    let onShare: () -> Void
    
    var body: some View {
        VStack {
            
            // Display the predicted image
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .shadow(radius: 5)
                .frame(width: 300, height: 300)
            
            
            
            VStack {
                
                // Top predictions header and share
                HStack {
                    Text("TopPredictions:".localized(using: currentLanguage))
                        .font(.title)
                        .padding()
                    
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(10)
                    }
                    .buttonStyle(.plain)
                    
                }
                
                // List of predictions with navigation
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
            .frame(maxWidth: 300)
            .background(Color("LimeGreen").opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
        }.environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        
        
    }
}
