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

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .shadow(radius: 5)
                .frame(width: 300, height: 300)

            VStack {
                Text("TopPredictions:".localized(using: currentLanguage))
                    .font(.title)
                    .padding()
                ForEach(predictions, id: \.0) { prediction in
                    NavigationLink(destination: Text(prediction.0)) {
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
                    }
                }
            }
            .frame(maxWidth: 300)
            .background(Color("LimeGreen").opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}
