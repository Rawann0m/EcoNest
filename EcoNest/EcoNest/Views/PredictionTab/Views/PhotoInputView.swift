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
    
    @State private var navigateToCreatePost = false
    
    private var selectedColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    private var defaultColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var shareText: String {
        viewModel.topPredictions.map { "\($0.0): \(String(format: "%.2f%%", $0.1))" }
            .joined(separator: "\n")
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
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
                                viewModel.clearPredictions()
                                selectedImage = uiImage
                                capturedImage = nil
                                selectedItem = nil
                                viewModel.runPrediction(for: uiImage)
                               
                            }
                        }
                    }
                    
                    if let image = selectedImage ?? capturedImage {
                        VStack {
                            PredictionResultView(
                                image: image,
                                predictions: viewModel.topPredictions,
                                currentLanguage: currentLanguage,
                                onShare: {
                                    navigateToCreatePost = true
                                }
                            )
                            
                            NavigationLink(
                                destination: CreatePost(
                                    message: shareText,
                                    communityId: "0ScXYeMDgcTz0pcDpkin",
                                    selectedImages: [image]
                                    
                                ),
                                isActive: $navigateToCreatePost
                            ) {
                                EmptyView()
                            }
                            .hidden()
                        }
                    } else {
                        ImagePlaceholderView()
                    }
                    
                    Spacer()
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            .alert("Not a plant?", isPresented: $viewModel.showAlert) {
                Button("Yes") {
                    // User wants to proceed anyway, so run the second model
                    viewModel.proceedWithPlantTypePrediction()
                }
                Button("No", role: .cancel) {
                    // User cancels, do nothing or reset if needed
                    selectedImage = nil
                    capturedImage = nil
                    
                }
            } message: {
                Text("This might not be a plant. Proceed anyway?")
            }

            
        }
    }
    
    private func sharePrediction(image: UIImage, text: String) {
        let activityVC = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
    
}
