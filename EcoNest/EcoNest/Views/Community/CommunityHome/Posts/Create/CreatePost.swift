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
    // MARK: - variabels
    @State var message: String = ""
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = CreatePostViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    var communityId: String
    @State var selectedImages: [UIImage] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State var showImagePicker: Bool = false
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var showCamera: Bool = false
    @StateObject var alertManager = AlertManager.shared
    @Binding var isLoading: Bool
    let imageCount = 4
    @State var showAlert: Bool = false
    // MARK: - UI Design
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                HStack(alignment: .center){
                    VStack{
                        if settingsViewModel.profileImage == "" {
                            Image("profile")
                                .resizable()
                        }  else if let imageURL = URL(string: settingsViewModel.profileImage){
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
                    
                    Text(settingsViewModel.name)
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
                            viewModel.checkUserIsAMember(communityId: communityId) { isMember in
                                if isMember{
                                    isLoading  = true
                                    PhotoUploaderManager.shared.uploadImages(images: selectedImages, isPost: true) { result in
                                        switch result {
                                        case .success(let urls):
                                            let contentArray = [message.trimmingCharacters(in: .whitespacesAndNewlines)] + urls.map { $0.absoluteString }
                                            viewModel.addPost(communityId: communityId, post: Post(userId: userId, content: contentArray, timestamp: Timestamp(), likes: []))
                                            isLoading  = false
                                            dismiss()
                                        case .failure(let error):
                                            print("Image upload failed: \(error.localizedDescription)")
                                        }
                                    }
                                } else {
                                    showAlert.toggle()
                                }
                                if !showAlert{
                                    dismiss()
                                }
                            }
                        }
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
                        .alert("Error".localized(using: currentLanguage), isPresented: $showAlert) {
                            Button("OK".localized(using: currentLanguage)) {
                                showAlert = false
                            }
                        } message: {
                            Text("You need to be a member of a community to post")
                        }
                        
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
                .ignoresSafeArea(.all)
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
                    if !canAddMoreImages() { return }
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImages.append(uiImage)
                        }
                    }
                }
            }
            .alert(isPresented: $alertManager.alertState.isPresented) {
                Alert(
                    title: Text(alertManager.alertState.title),
                    message: Text(alertManager.alertState.message),
                    primaryButton: .default(Text("OK".localized(using: currentLanguage))) {
                        
                    },
                    secondaryButton: .cancel(Text("Cancel".localized(using: currentLanguage)))
                )
            }
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
    
