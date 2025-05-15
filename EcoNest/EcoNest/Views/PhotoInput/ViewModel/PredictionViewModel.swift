//
//  PredictionViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

class PredictionViewModel: ObservableObject {
    @Published var topPredictions: [(String, Float)] = []

    func runPrediction(for image: UIImage) {
        let handler = MLModelHandler()
        handler.topPredictions = { [weak self] predictions in
            self?.topPredictions = predictions
        }
        handler.predictPlantType(from: image)
    }
}
