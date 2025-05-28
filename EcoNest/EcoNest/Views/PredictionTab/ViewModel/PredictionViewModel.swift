//
//  PredictionViewModel.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

/// Manages image-based plant prediction using a machine learning handler.
///
/// `PredictionViewModel` sends a user-selected image to a `MLModelHandler` to determine whether
/// the image contains a plant, and if so, predicts the plant type.
/// The results are published and can be displayed in the UI.
class PredictionViewModel: ObservableObject {
    
    /// Top predicted plant types with confidence scores.
    @Published var topPredictions: [(String, Float)] = []
    
    /// Indicates whether a "not a plant" alert should be shown.
    @Published var showAlert = false

    /// The image currently being processed.
    private var currentImage: UIImage?
    
    /// Handles ML model inference for image classification.
    private var mlHandler = MLModelHandler()

    /// Runs the initial prediction to determine if the image contains a plant.
        /// If the image is valid, proceeds with plant type prediction.
        /// - Parameter image: The `UIImage` selected by the user.
    func runPrediction(for image: UIImage) {
        currentImage = image
        
        // Setup callback for plant-or-not classification
        mlHandler.pPredictionUpdated = { [weak self] prediction in
            DispatchQueue.main.async {
                if prediction.label == "not_plant" {
                    self?.showAlert = true
                } else {
                    
                    // If a plant is detected, run detailed type prediction
                    if let img = self?.currentImage {
                        self?.mlHandler.predictPlantType(from: img)
                    }
                }
            }
        }

        // Setup callback for top type predictions
        mlHandler.topPredictions = { [weak self] predictions in
            DispatchQueue.main.async {
                self?.topPredictions = predictions
            }
        }
        
        // Trigger first step: is it a plant?
        mlHandler.predictPlantOrNot(image: image)
    }

    /// Continues with plant type prediction after dismissing the non-plant alert.
    func proceedWithPlantTypePrediction() {
        if let img = currentImage {
            mlHandler.predictPlantType(from: img)
        }
        showAlert = false
    }
    
    /// Clears any existing prediction results.
    func clearPredictions() {
            topPredictions = []
        }

}
