//
//  PhotoInputButtons.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

/// Displays animated buttons for selecting or capturing a photo,
/// with prediction and camera integration.
///
/// `PhotoInputButtons` toggles between two actions: selecting an image from the library or taking a photo with the camera.
/// It uses a `PredictionViewModel` to clear and initiate plant prediction,
/// and utilizes a custom `CameraManager` for camera presentation.
struct PhotoInputButtons: View {
    
    /// Indicates the current button state (true = select photo, false = take photo).
    @Binding var buttonSelected: Bool
    
    /// Controls whether the photo picker should be shown.
    @Binding var showPicker: Bool
    
    /// Stores the captured image (camera).
    @Binding var capturedImage: UIImage?
    
    /// Stores the selected image (library).
    @Binding var selectedImage: UIImage?
    
    /// The current language code for localization and layout direction.
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Namespace for shared animation between capsules.
    @Namespace var namespace
    
    /// Foreground color for the selected button.
    var selectedColor: Color
    
    /// Foreground color for the unselected button.
    var defaultColor: Color
    
    /// Camera interaction manager.
    var cameraManager: CameraManager
    
    /// View model for plant prediction handling.
    var viewModel: PredictionViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Photo Selection Button
            ZStack {
                if buttonSelected {
                    Capsule()
                        .fill(Color("LimeGreen"))
                        .matchedGeometryEffect(id: "Type", in: namespace)
                        .frame(width: 160, height: 50)
                        .padding(.horizontal)
                }

                Button {
                    withAnimation(.easeInOut) {
                        buttonSelected = true
                    }
                    viewModel.clearPredictions()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showPicker = true
                    }
                } label: {
                    HStack {
                        Text("SelectPhoto".localized(using: currentLanguage))
                        Image(systemName: "photo.tv")
                    }
                    .font(.headline)
                    .frame(width: 150, height: 50)
                    .foregroundColor(buttonSelected ? selectedColor : defaultColor)
                }
            }

            // Take Photo Button
            ZStack {
                if !buttonSelected {
                    Capsule()
                        .fill(Color("LimeGreen"))
                        .matchedGeometryEffect(id: "Type", in: namespace)
                        .frame(width: 160, height: 50)
                }

                Button {
                    withAnimation(.easeInOut) {
                        buttonSelected = false
                    }
                    viewModel.clearPredictions()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let root = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first?.windows
                            .first(where: \.isKeyWindow)?
                            .rootViewController {
                            cameraManager.onImagePicked = { image in
                                capturedImage = image
                                selectedImage = nil
                                viewModel.runPrediction(for: image)
                            }
                            cameraManager.presentCamera(from: root)
                        }
                    }
                } label: {
                    HStack {
                        Text("TakePhoto".localized(using: currentLanguage))
                        Image(systemName: "camera")
                    }
                    .font(.headline)
                    .frame(width: 150, height: 50)
                    .foregroundColor(!buttonSelected ? selectedColor : defaultColor)
                }
            }
        }
    }
}
