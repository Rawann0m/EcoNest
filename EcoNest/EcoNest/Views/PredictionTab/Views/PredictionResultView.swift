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
                .frame(width: 300, height: 300)
            
            
            
            VStack {
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
                ForEach(predictions, id: \.0) { prediction in
                    NavigationLink(destination: PlantDetails(plantName: prediction.0)) {
                        HStack {
                            Text(prediction.0)
                                .font(.body)
                                .padding(.bottom)
                                .padding(.leading)
                            Spacer()
                            Text(String(format: "%.2f%%", prediction.1))
                                .font(.body)
                                .padding(.bottom)
                                .padding(.trailing)
                        }
                    }.foregroundColor(.primary)
                }
                

                
            }
            .frame(maxWidth: 300)
            .background(Color("LimeGreen").opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        
        
    }
}
