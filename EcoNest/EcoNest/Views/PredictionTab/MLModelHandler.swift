//
//  MLModelHandler.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 14/05/2025.
//

import SwiftUI
import CoreML
import Vision

/// Handles CoreML prediction flows for detecting plant presence and identifying plant types.
///
/// `MLModelHandler` preprocesses UIImages, runs them through CoreML models using Vision,
/// and provides results via closures for easy SwiftUI integration.
class MLModelHandler{
    
    /// Callback delivering top plant type predictions (label, confidence).
    var topPredictions: (([(String, Float)]) -> Void)?
    
    /// Callback for binary classification: plant or not.
    @Published var showAlert = false
    
    /// Internal storage for binary classification result.
    var pPredictionUpdated: (( (label: String, confidence: Float) ) -> Void)?
    
    var pPrediction: (label: String, confidence: Float)? {
        didSet {
            if let prediction = pPrediction {
                pPredictionUpdated?(prediction)
            }
        }
    }
    
    /// Preprocesses a `UIImage` by resizing it and converting to `CVPixelBuffer`.
    /// - Parameters:
    ///   - image: The source image.
    ///   - targetSize: Desired image size for model input.
    /// - Returns: A CoreML-compatible pixel buffer or `nil`.
    func preprocessImage(_ image: UIImage, targetSize: CGSize = CGSize(width: 160, height: 160)) -> CVPixelBuffer? {
        // Step 1: Resize the image
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 2.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Step 2: Convert to CVPixelBuffer
        guard let resizedUIImage = resizedImage else {
            print("Failed to resize UIImage")
            return nil
        }
        
        guard let pixelBuffer = resizedUIImage.toCVPixelBuffer() else {
            print("Failed to convert UIImage to CVPixelBuffer")
            return nil
        }
        
        return pixelBuffer
    }
    
    /// Uses the `PlantOrNotClassifier` model to detect if an image contains a plant.
    /// - Parameter image: Input image to classify.
    func predictPlantOrNot(image: UIImage) {
        guard let pixelBuffer = preprocessImage(image) else {
            print("Failed to preprocess image")
            return
        }
        
        do {
            let model = try VNCoreMLModel(for: PlantOrNotClassifier().model)
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation],
                   let topResult = results.first {
                    DispatchQueue.main.async {
                        let prediction = (label: topResult.identifier, confidence: topResult.confidence)
                        self.pPrediction = prediction
                        self.pPredictionUpdated?(prediction)
                    }
                }
            }
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
        } catch {
            print("Prediction failed: \(error)")
        }
    }
    
    /// Uses the `PlantClassifier_KfoldBestB3` model to identify the plant type from an image.
    /// Returns top 5 predictions with normalized confidence scores.
    /// - Parameter image: Image to classify.
    func predictPlantType(from image: UIImage) {
        print("Loading the model...")
        
        guard let model = try? PlantClassifier_KfoldBestB3(configuration: MLModelConfiguration()) else {
            print("Failed to load model")
            return
        }
        
        print("Model loaded successfully.")
        
        guard let pixelBuffer = preprocessImage(image) else {
            print("Failed to preprocess image")
            return
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
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
    
    /// Converts an array of confidence scores to a softmax-normalized distribution.
    func softmax() -> [Float] {
        let expValues = self.map { exp($0) }
        let sumExp = expValues.reduce(0, +)
        return expValues.map { $0 / sumExp }
    }
}
