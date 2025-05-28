//
//  PredictionViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

class PredictionViewModel: ObservableObject {
    @Published var topPredictions: [(String, Float)] = []
    @Published var showAlert = false

    private var currentImage: UIImage?
    private var mlHandler = MLModelHandler()

    func runPrediction(for image: UIImage) {
        currentImage = image
        mlHandler.pPredictionUpdated = { [weak self] prediction in
            DispatchQueue.main.async {
                if prediction.label == "not_plant" {
                    self?.showAlert = true
                } else {
                    // If it is plant, run prediction
                    if let img = self?.currentImage {
                        self?.mlHandler.predictPlantType(from: img)
                    }
                }
            }
        }

        mlHandler.topPredictions = { [weak self] predictions in
            DispatchQueue.main.async {
                self?.topPredictions = predictions
            }
        }

        mlHandler.predictPlantOrNot(image: image)
    }

    func proceedWithPlantTypePrediction() {
        if let img = currentImage {
            mlHandler.predictPlantType(from: img)
        }
        showAlert = false
    }
    
    func clearPredictions() {
            topPredictions = []
        }

}
