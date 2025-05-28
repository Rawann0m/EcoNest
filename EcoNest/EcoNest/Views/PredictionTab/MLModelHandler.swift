//
//  MLModelHandler.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 14/05/2025.
//

import SwiftUI
import CoreML
import Vision

/// Handles CoreML model inference for binary plant detection and multiclass plant classification.
class MLModelHandler{
    // MARK: - Prediction Output Closures
    var topPredictions: (([(String, Float)]) -> Void)?
    @Published var showAlert = false
    var pPredictionUpdated: (( (label: String, confidence: Float) ) -> Void)?
    
    var pPrediction: (label: String, confidence: Float)? {
        didSet {
            if let prediction = pPrediction {
                pPredictionUpdated?(prediction)
            }
        }
    }
    
    // MARK: - Image Preprocessing
    
    /// Resizes a UIImage and converts it to a `CVPixelBuffer` for CoreML input.
    ///
    /// - Parameters:
    ///   - image: The input UIImage.
    ///   - targetSize: The size to which the image should be resized (default is 160x160).
    /// - Returns: A `CVPixelBuffer` or nil if conversion fails.
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
    
    // MARK: - Binary Classification ("Plant or Not")

    /// Runs prediction using the `PlantOrNotClassifier` model to classify whether an image is of a plant or not.
    ///
    /// - Parameter image: The input UIImage to classify.
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
    // MARK: - Multiclass Classification ("Plant Type")

    /// Runs prediction using the `PlantClassifier_KfoldBestB3` model to classify the type of plant.
    ///
    /// - Parameter image: The input UIImage to classify.
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
    func softmax() -> [Float] {
        let expValues = self.map { exp($0) }
        let sumExp = expValues.reduce(0, +)
        return expValues.map { $0 / sumExp }
    }
}
