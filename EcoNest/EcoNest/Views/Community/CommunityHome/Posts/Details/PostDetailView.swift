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
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = post.user, let post = viewModel.selectedPost  {
                        Posts(post: post, user: user, communityId: communityId, viewModel: viewModel)
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
                                            selectedItems.remove(at: index)
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
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 28))
                                .foregroundColor(Color("DarkGreen"))
                                .onTapGesture {
                                    showImagePicker.toggle()
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
                                if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                                    PhotoUploaderManager.shared.uploadImages(images: selectedImages) { result in
                                        switch result {
                                        case .success(let urls):
                                            let contentArray = [newReply] + urls.map { $0.absoluteString }
                                            if let postId = self.post.id{
                                                viewModel.addReplyToPost(communityId: communityId, postId: postId, replay: Post(userId: userId, content: contentArray, timestamp: Timestamp(), likes: []))
                                                
                                            }
                                        case .failure(let error):
                                            print("Image upload failed: \(error.localizedDescription)")
                                        }
                                        newReply = ""
                                        selectedImages.removeAll()
                                        selectedItems.removeAll()
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
                    .padding()
                    .background(themeManager.isDarkMode ? .black : .white)
                }
            }
        }
        .onAppear{
            if let postId = self.post.id{
                viewModel.getPostsReplies(communityId: communityId, postId: postId)
                
                viewModel.listenToSelectedPost(communityId: communityId, postId: postId)
            }
        }
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $selectedItems,
            maxSelectionCount: 4,
            matching: .images
        )
        .onChange(of: selectedItems) { _, newItems in
            Task {
                selectedImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(uiImage)
                    }
                }
            }
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
    
    var textEmpty: Bool {
        let text = newReply.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty
    }
}
