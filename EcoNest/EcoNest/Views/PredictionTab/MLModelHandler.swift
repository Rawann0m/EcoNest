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
        
        let targetSize = CGSize(width: 224, height: 224)
        let resizedImage = ciImage.transformed(by: CGAffineTransform(scaleX: targetSize.width / ciImage.extent.width,
                                                                     y: targetSize.height / ciImage.extent.height))
        return resizedImage
    }
    
    func predictPlantType(from image: UIImage) {
        print("Loading the model...")
        
        guard let model = try? PlantClassifier_KfoldBestB3(configuration: MLModelConfiguration()) else {
            print("Failed to load model")
            return
        }
        
        print("Model loaded successfully.")
        
        guard let ciImage = preprocessImage(image) else {
            print("Failed to preprocess image")
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: model.model)) { request, _ in
            if let results = request.results as? [VNClassificationObservation] {
                let identifiers = results.map { $0.identifier }
                let rawValues = results.map { $0.confidence }
                let normalized = rawValues.softmax().map { $0 * 100 }
                
                let top5 = zip(identifiers, normalized)
                    .sorted { $0.1 > $1.1 }
                    .prefix(5)
                
                DispatchQueue.main.async {
                    self.topPredictions?(Array(top5))
                    for prediction in top5 {
                        print("Prediction: \(prediction.0) - Confidence: \(prediction.1)")
                    }
                }
            } else {
                print("No result returned from VNCoreMLRequest")
            }
        }
        
        do {
            try handler.perform([request])
            print("VNImageRequestHandler performed successfully.")
        } catch {
            print("Failed to perform request: \(error)")
        }
    }
}

// MARK: - Softmax Extension

extension Array where Element == Float {
    func softmax() -> [Float] {
        let expValues = self.map { exp($0) }
        let sumExp = expValues.reduce(0, +)
        return expValues.map { $0 / sumExp }
    }
}
