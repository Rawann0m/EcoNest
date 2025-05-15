//
//  PhotoInputView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 11/05/2025.
//
// PhotoInputView.swift

import SwiftUI
import Vision
import PhotosUI

struct PhotoInputView: View {
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @Namespace private var namespace
    @State private var buttonselected = true
    @State private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage? = nil
    @StateObject private var viewModel = PredictionViewModel()
    @State private var uploader = FireStoreUploader()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
//                Button("Check JSON File") {
//                    if let url = Bundle.main.url(forResource: "plants", withExtension: "json") {
//                        print("✅ Found JSON file at: \(url)")
//                    } else {
//                        print("❌ JSON file not found!")
//                    }
//                }
//                
//                Button("Upload Plants") {
//                    if let plants = uploader.loadPlantsFromJSON() {
//                        uploader.uploadPlantsToFirestore(plants: plants)
//                    }
//                }
                
                HStack(spacing: 16) {
                    
                    ZStack {
                        if buttonselected {
                            Capsule()
                                .fill(Color.blue)
                                .matchedGeometryEffect(id: "Type", in: namespace)
                                .frame(width: 160, height: 50)
                        }
                        
                        // Wrap in button to control tap timing
                        Button {
                            withAnimation(.easeInOut) {
                                buttonselected = true
                            }
                            
                            // Trigger the actual PhotosPicker with delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                                showPicker = true
                            }
                        } label: {
                            HStack {
                                Text("Select Photo")
                                Image(systemName: "photo.tv")
                            }
                            .font(.headline)
                            .frame(width: 150, height: 50)
                            .foregroundColor(buttonselected ? .white : .black)
                        }
                    }
                    
                    ZStack {
                        if !buttonselected {
                            Capsule()
                                .fill(Color.blue)
                                .matchedGeometryEffect(id: "Type", in: namespace)
                                .frame(width: 160, height: 50)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                buttonselected = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                                if let root = UIApplication.shared.connectedScenes
                                    .compactMap({ $0 as? UIWindowScene })
                                    .first?.windows
                                    .first(where: \.isKeyWindow)?
                                    .rootViewController {
                                    
                                    cameraManager.onImagePicked = { image in
                                        self.capturedImage = image
                                        self.selectedImage = nil
                                        viewModel.runPrediction(for: image)  // This handles captured image
                                    }
                                    cameraManager.presentCamera(from: root)
                                }
                            }
                        }) {
                            HStack {
                                Text("Take Photo")
                                Image(systemName: "camera")
                            }
                            .font(.headline)
                            .frame(width: 150, height: 50)
                            .foregroundColor(!buttonselected ? .white : .black)
                            
                            
                            
                        }
                    }
                    
                    
                }.photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) { oldItem, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                self.selectedImage = uiImage
                                self.capturedImage = nil
                                self.selectedItem = nil
                                viewModel.runPrediction(for: uiImage)
                            }
                        }
                    }
                
                
                
                
                
                if let image = selectedImage ?? capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .frame(width: 300, height: 300)
                    
                    VStack {
                        HStack{
                            Text("Plant Type")
                                .font(.body)
                                .padding()
                            Spacer()
                            Text("Confidence")
                                .font(.body)
                                .padding()
                        }
                        ForEach(viewModel.topPredictions, id: \.0) { prediction in
                            HStack {
                                Text("\(prediction.0)")
                                    .font(.body)
                                    .padding(.bottom)
                                    .padding(.leading)
                                Spacer()
                                Text("\(String(format: "%.2f", prediction.1))")
                                    .font(.body)
                                    .padding(.bottom)
                                    .padding(.trailing)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                    .background(Color.blue.opacity(0.9))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 300, height: 300)
                        .overlay(Text("Choose or Take a Photo"), alignment: .center)
                        .cornerRadius(15)
                }
                
                
                Spacer()
                Spacer()
            }
        }.scrollIndicators(.hidden)
    }
    
    
}
