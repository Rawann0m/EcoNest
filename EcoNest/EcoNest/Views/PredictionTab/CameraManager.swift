//
//  CameraManager.swift
//  PlayGround
//
//  Created by Abdullah Hafiz on 13/05/2025.
//

import SwiftUI

class CameraManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var onImagePicked: ((UIImage) -> Void)?

    func presentCamera(from root: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        root.present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            onImagePicked?(image)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
