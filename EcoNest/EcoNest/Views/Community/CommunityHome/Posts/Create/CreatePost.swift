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
    @StateObject var settingsViewModel = SettingsViewModel()
    var communityId: String
    @State var selectedImages: [UIImage] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State var showImagePicker: Bool = false
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                HStack(alignment: .top){
                    
                    VStack{
                        if settingsViewModel.user?.profileImage == nil {
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
                    
                    Spacer()
                }
                
                TextEditor(text: $message)
                
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
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
                    .background{
                        Circle()
                            .fill(Color("LimeGreen"))
                            .frame(width: 50, height: 50)
                    }
                    .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Cancel")
                        .onTapGesture {
                            dismiss()
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button{
                        if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                            viewModel.uploadImages(images: selectedImages) { result in
                                switch result {
                                case .success(let urls):
                                    let contentArray = [message] + urls.map { $0.absoluteString }
                                    viewModel.addPost(communityId: communityId, post: Post(userId: userId, content: contentArray, timestamp: Timestamp(), likes: []))
                                    dismiss()
                                case .failure(let error):
                                    print("Image upload failed: \(error.localizedDescription)")
                                }
                            }
                        }
    
                        dismiss()
                        
                    } label: {
                        Text("Post")
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
    }
    
    var textEmpty: Bool {
        let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty
    }
}

