//
//  PostDetailView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore
import PhotosUI

struct PostDetailView: View {
    // MARK: - variabels
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @EnvironmentObject var themeManager: ThemeManager
    let post: Post
    let communityId: String
    @ObservedObject var viewModel: PostsListViewModel
    @State private var replies: [Post] = []
    @State private var newReply: String = ""
    @Environment(\.dismiss) var dismiss
    @State var selectedImages: [UIImage] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State var showImagePicker: Bool = false
    @State private var showCamera: Bool = false
    @StateObject var alertManager = AlertManager.shared
    let imageCount = 4
    // MARK: - UI Design
    var body: some View {
        ZStack{
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let user = post.user, let post = viewModel.selectedPost  {
                            Posts(post: post, user: user, communityId: communityId, viewModel: viewModel,isReplay: false, postId: post.id)
                                .onChange(of: viewModel.didDeleteSelectedPost) { _, deleted in
                                    if deleted {
                                        dismiss()
                                        viewModel.didDeleteSelectedPost = false
                                    }
                                }
                        }
                    }
                    
                    if viewModel.isLoading{
                        ProgressView()
                            .frame(height: 350, alignment: .center)
                    } else {
                        if !viewModel.postReplies.isEmpty {
                            Text("Replies".localized(using: currentLanguage))
                                .font(.headline)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(viewModel.postReplies.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })) { reply in
                                if let user = reply.user {
                                    Posts(post: reply, user: user, communityId: communityId, viewModel: viewModel, isReplay: true, postId: post.id)
                                }
                            }
                        } else {
                            Text("Norepliesyet".localized(using: currentLanguage))
                                .foregroundColor(.secondary)
                                .frame(height: 300, alignment: .center)
                                .padding()
                        }
                    }
                    
                }
                .navigationTitle("PostDetails".localized(using: currentLanguage))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.primary)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if FirebaseManager.shared.isLoggedIn {
                        VStack{
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
                            
                            HStack {
                                Menu{
                                    Button("Camera") {
                                        if canAddMoreImages() {
                                            showCamera = true
                                        } else {
                                            showMaxImagesAlert()
                                        }
                                    }
                                    
                                    Button("Photo Picker") {
                                        if canAddMoreImages() {
                                            showImagePicker.toggle()
                                        } else {
                                            showMaxImagesAlert()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 28))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LightGreen") : Color("DarkGreen"))
                                }
                                
                                ZStack{
                                    Text("TypeReplay".localized(using: currentLanguage))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                    TextEditor(text: $newReply)
                                        .frame(height: 25)
                                        .opacity(newReply.isEmpty ? 0.5 : 1)
                                }
                                
                                Button("Reply".localized(using: currentLanguage)) {
                                    let replay = newReply
                                    let images = selectedImages
                                    newReply = ""
                                    selectedImages.removeAll()
                                    selectedItems.removeAll()
                                    if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                                        PhotoUploaderManager.shared.uploadImages(images: images, isPost: true) { result in
                                            switch result {
                                            case .success(let urls):
                                                let contentArray = [replay] + urls.map { $0.absoluteString }
                                                if let postId = self.post.id{
                                                    viewModel.addReplyToPost(communityId: communityId, postId: postId, replay: Post(userId: userId, content: contentArray, timestamp: Timestamp(), likes: []))
                                                    
                                                }
                                            case .failure(let error):
                                                print("Image upload failed: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                    
                                }
                                .disabled(textEmpty)
                                .padding(10)
                                .foregroundColor(.white)
                                .background{
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(textEmpty ? .gray : Color("LimeGreen"))
                                }
                            }
                        }
                        .frame(height: selectedImages.isEmpty ? 30: 150)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        .background(themeManager.isDarkMode ? .black : .white)
                    }
                }
            }
            if viewModel.showPic {
                if let pic = viewModel.selectedPic {
                    PicView(pic: pic, showPic: $viewModel.showPic)
                }
            }
            
        }
        .onAppear{
            if let postId = self.post.id{
                viewModel.getPostsReplies(communityId: communityId, postId: postId)
                viewModel.listenToSelectedPost(communityId: communityId, postId: postId)
            }
            
            viewModel.showPic = false
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
                for item in newItems {
                    if !canAddMoreImages() { break }
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
        let text = newReply.trimmingCharacters(in: .whitespacesAndNewlines)
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
