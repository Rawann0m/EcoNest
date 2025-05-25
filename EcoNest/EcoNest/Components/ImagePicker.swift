//
//  ImagePicker.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 22/11/1446 AH.
//

import UIKit
import SwiftUI
/// A SwiftUI wrapper for `UIImagePickerController`, allowing image selection from the photo library or camera.
///
/// `ImagePicker` uses `UIViewControllerRepresentable` to present a UIKit-based image picker inside a SwiftUI view.
/// It supports selecting an image and returns the selected image through a completion handler.
///
/// - Parameters:
///   - sourceType: The source from which to pick the image (e.g., `.photoLibrary` or `.camera`). Default is `.photoLibrary`.
///   - completionHandler: A closure that is executed with the selected `UIImage` after the user picks an image.
struct ImagePicker: UIViewControllerRepresentable {
    // The source type for the image picker (photo library or camera).
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Closure to return the selected image to the caller.
    var completionHandler: (UIImage) -> Void

    // Creates the coordinator responsible for handling delegate methods.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates and configures the `UIImagePickerController` instance.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }

    // Required method but unused in this case as the picker doesn't need updating.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    // Coordinator class to bridge UIKit delegate callbacks to SwiftUI.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        // Reference to the parent `ImagePicker` for calling the completion handler.
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called when the user selects an image.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.completionHandler(image)
            }
        }

        // Called when the user cancels the image picker.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
