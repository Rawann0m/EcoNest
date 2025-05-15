//
//  PhotoInputButtons.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct PhotoInputButtons: View {
    @Binding var buttonSelected: Bool
    @Binding var showPicker: Bool
    @Binding var capturedImage: UIImage?
    @Binding var selectedImage: UIImage?
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Namespace var namespace
    var selectedColor: Color
    var defaultColor: Color
    var cameraManager: CameraManager
    var viewModel: PredictionViewModel

    var body: some View {
        HStack(spacing: 16) {
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
