//
//  CreatePost.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI
import PhotosUI

struct CreatePost: View {
    @State var message: String = ""
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = CreatePostViewModel()
    @ObservedObject var settingsViewModel = SettingsViewModel()
    var communityId: String
    @State var selectedImages: [UIImage] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State var showImagePicker: Bool = false
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var showCamera: Bool = false
    @StateObject var alertManager = AlertManager.shared
    let imageCount = 4
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                HStack(alignment: .center){
                    VStack{
                        if settingsViewModel.user?.profileImage == "" {
                            Image("profile")
                                .resizable()
                        }  else if let imageURL = URL(string: settingsViewModel.user?.profileImage ?? ""){
                            WebImage(url: imageURL)
                                .resizable()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(50)
                    .background{
                        Circle()
                            .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                    }
                    
                    Text(settingsViewModel.user?.username ?? "User")
                        .bold()
                }
                
                
                ZStack(alignment: .topLeading){
                    Text("TypeMessage".localized(using: currentLanguage))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    TextEditor(text: $message)
                        .opacity(message.isEmpty ? 0.5 : 1)
                }
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    selectedImages.remove(at: index)
                                    if !selectedItems.isEmpty {
                                        selectedItems.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .offset(x: -5, y: 5)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .scrollIndicators(.hidden)
                
                Menu {
                    Button("Camera") {
                        if canAddMoreImages() {
                            showCamera = true
                        } else {
                            showMaxImagesAlert()
                        }
                    }
                    
                    Button("Photo Picker") {
                        if canAddMoreImages() {
                            showImagePicker = true
                        } else {
                            showMaxImagesAlert()
                        }
                    }
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .background {
                            Circle()
                                .fill(Color("LimeGreen"))
                                .frame(width: 50, height: 50)
                        }
                        .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Cancel".localized(using: currentLanguage))
                        .onTapGesture {
                            dismiss()
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button{
                        if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                            PhotoUploaderManager.shared.uploadImages(images: selectedImages) { result in
                                switch result {
                                case .success(let urls):
                                    let contentArray = [message.trimmingCharacters(in: .whitespacesAndNewlines)] + urls.map { $0.absoluteString }
                                    viewModel.addPost(communityId: communityId, post: Post(userId: userId, content: contentArray, timestamp: Timestamp(), likes: []))
                                    dismiss()
                                case .failure(let error):
                                    print("Image upload failed: \(error.localizedDescription)")
                                }
                            }
                        }
                        
                        dismiss()
                        
                    } label: {
                        Text("Post".localized(using: currentLanguage))
                            .padding(10)
                            .bold()
                            .foregroundColor(.white)
                            .background{
                                Capsule()
                                    .fill(textEmpty ? .gray : Color("LimeGreen"))
                            }
                    }
                    .disabled(textEmpty)
                    
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                if canAddMoreImages() {
                    selectedImages.append(image)
                } else {
                    showMaxImagesAlert()
                }
            }
        }
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $selectedItems,
            maxSelectionCount: imageCount - selectedImages.count,
            matching: .images
        )
        .onChange(of: selectedItems) { _, newItems in
            Task {
                selectedItems = []
                for item in newItems {
                    if !canAddMoreImages() { break }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(uiImage)
                    }
                }
            }
        }
//        .onChange(of: selectedItems) { _, newItems in
//            Task {
//                var tempImages: [UIImage] = []
//                
//                for item in newItems {
//                    if tempImages.count + selectedImages.count >= imageCount { break }
//
//                    if let data = try? await item.loadTransferable(type: Data.self),
//                       let uiImage = UIImage(data: data) {
//                        tempImages.append(uiImage)
//                    }
//                }
//
//                let spaceLeft = imageCount - selectedImages.count
//                if spaceLeft > 0 {
//                    selectedImages += tempImages.prefix(spaceLeft)
//                }
//
//                selectedItems = []
//            }
//        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
    
    var textEmpty: Bool {
        let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty
    }
    
    func showMaxImagesAlert() {
        AlertManager.shared.showAlert(
            title: "Error".localized(using: currentLanguage),
            message: "You can upload up to \(imageCount) images only.".localized(using: currentLanguage)
        )
    }
    
    func canAddMoreImages() -> Bool {
        return selectedImages.count < imageCount
    }
}

