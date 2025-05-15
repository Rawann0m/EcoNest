//
//  MLModelHandler.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 14/05/2025.
//

import SwiftUI
import CoreML
import Vision

class MLModelHandler {
    var topPredictions: (([(String, Float)]) -> Void)?
    
    func preprocessImage(_ image: UIImage) -> CIImage? {
        guard let ciImage = CIImage(image: image) else {
            print("Failed to convert UIImage to CIImage")
            return nil
        }
        
        // Resize the image to 224x224 (assuming that's what the model expects)
        let targetSize = CGSize(width: 224, height: 224)
        let resizedImage = ciImage.transformed(by: CGAffineTransform(scaleX: targetSize.width / ciImage.extent.width,
                                                                     y: targetSize.height / ciImage.extent.height))
        return resizedImage
    }
    
    func predictPlantType(from image: UIImage) {
        // Log to check if the model is being loaded correctly
        print("Loading the model...")
        
        guard let model = try? PlantClassifier_KfoldBestB3(configuration: MLModelConfiguration()) else {
            print("Failed to load model")
            return
        }
        
        // Log to confirm model loading
        print("Model loaded successfully.")
        
        guard let ciImage = preprocessImage(image) else {
            print("Failed to preprocess image")
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: model.model)) { request, _ in
            if let results = request.results as? [VNClassificationObservation] {
                // Sort the results by confidence and get the top 5 predictions
                let sortedResults = results.sorted { $0.confidence > $1.confidence }
                let top5 = sortedResults.prefix(5).map { ($0.identifier, $0.confidence) }
                
                DispatchQueue.main.async {
                    // Update the UI with top 5 predictions
                    self.topPredictions?(top5)
                    for prediction in top5 {
                        print("Prediction: \(prediction.0) - Confidence: \(prediction.1)")
                    }
                }
            } else {
                print("No result returned from VNCoreMLRequest")
            }
        }
        
        do {
            // Perform the request and log if successful
            try handler.perform([request])
            print("VNImageRequestHandler performed successfully.")
        } catch {
            print("Failed to perform request: \(error)")
        }
    }
}
