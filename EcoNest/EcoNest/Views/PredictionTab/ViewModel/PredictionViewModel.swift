//
//  PredictionViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

/// ViewModel for managing prediction flow from image input to CoreML output.
class PredictionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var topPredictions: [(String, Float)] = []
    @Published var showAlert = false
    private var currentImage: UIImage?
    private var mlHandler = MLModelHandler()

    // MARK: - Prediction Flow

    /// Initiates the prediction pipeline by first determining if the image is of a plant.
    ///
    /// If a plant is detected, the view model proceeds to predict the plant type.
    ///
    /// - Parameter image: The input `UIImage` to analyze.
    func runPrediction(for image: UIImage) {
        currentImage = image
        
        // Set handler for binary prediction ("plant or not")
        mlHandler.pPredictionUpdated = { [weak self] prediction in
            DispatchQueue.main.async {
                if prediction.label == "not_plant" {
                    self?.showAlert = true
                } else {
                    // If it's a plant, predict the type
                    if let img = self?.currentImage {
                        self?.mlHandler.predictPlantType(from: img)
                    }
                }
            }
        }
        
        // Set handler for top-5 class predictions
        mlHandler.topPredictions = { [weak self] predictions in
            DispatchQueue.main.async {
                self?.topPredictions = predictions
            }
        }
        
        // Start binary classification
        mlHandler.predictPlantOrNot(image: image)
    }
    
    /// Called when the user chooses to proceed with plant type prediction after an alert.
    func proceedWithPlantTypePrediction() {
        if let img = currentImage {
            mlHandler.predictPlantType(from: img)
        }
        showAlert = false
    }
    
    /// Clears any stored predictions.
    func clearPredictions() {
            topPredictions = []
        }

}
