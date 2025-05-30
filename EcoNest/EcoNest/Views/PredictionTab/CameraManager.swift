//
//  CameraManager.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 13/05/2025.
//

import SwiftUI


/// A lightweight UIKit-compatible camera presenter for capturing images within a SwiftUI app.
///
/// `CameraManager` wraps `UIImagePickerController` to provide camera functionality in SwiftUI views.
/// It uses a closure to deliver the captured `UIImage` back to the SwiftUI context.
class CameraManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Shared singleton instance for global camera access.
    static let shared = CameraManager()
    
    /// Callback triggered when a photo is successfully captured.
    var onImagePicked: ((UIImage) -> Void)?
    
    
    /// Presents the camera interface modally from a given root view controller.
    /// - Parameter root: The UIViewController used to present the camera picker.
    func presentCamera(from root: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        root.present(picker, animated: true)
    }
    
    /// Called when the user picks an image from the camera.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            onImagePicked?(image)
        }
        picker.dismiss(animated: true)
    }
    
    /// Called when the user cancels the camera without taking a picture.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
