//
//  PredictionView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 11/05/2025.
//

import SwiftUI
import Vision
import PhotosUI

struct PredictionView: View {
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @Namespace private var namespace
    @State private var buttonSelected = true
    @State private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage? = nil
    @StateObject private var viewModel = PredictionViewModel()
    
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    private var selectedColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var defaultColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PhotoInputButtons(
                    buttonSelected: $buttonSelected,
                    showPicker: $showPicker,
                    capturedImage: $capturedImage,
                    selectedImage: $selectedImage,
                    currentLanguage: currentLanguage,
                    namespace: _namespace,
                    selectedColor: selectedColor,
                    defaultColor: defaultColor,
                    cameraManager: cameraManager,
                    viewModel: viewModel
                )
                .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) { oldItem, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            capturedImage = nil
                            selectedItem = nil
                            viewModel.runPrediction(for: uiImage)
                        }
                    }
                }

                if let image = selectedImage ?? capturedImage {
                    PredictionResultView(
                        image: image,
                        predictions: viewModel.topPredictions,
                        currentLanguage: currentLanguage
                    )
                } else {
                    ImagePlaceholderView()
                }

                Spacer()
            }
        }
        .scrollIndicators(.hidden)
    }
}
