//
//  Chat.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

struct ChatView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.dismiss) var dismiss
    @State var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State var showImagePicker: Bool = false
    @StateObject var viewModel: ChatViewModel
    let chatUser: User?
    @State var showPic: Bool = false
    init(chatUser: User?){
        self.chatUser = chatUser
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatUser: chatUser))
    }
    var body: some View {
        ZStack{
            NavigationStack{
                VStack{
                    ScrollView{
                        ScrollViewReader{ proxy in
                            ForEach(viewModel.chatMessages) { message in
                                ForEach(message.content, id: \.self) { contentItem in
                                    VStack {
                                        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                                            HStack {
                                                Spacer()
                                                if contentItem.lowercased().hasPrefix("http"),
                                                   let url = URL(string: contentItem) {
                                                    WebImage(url: url)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 350 ,height: 200)
                                                        .clipped()
                                                        .cornerRadius(10)
                                                        .onTapGesture {
                                                            viewModel.selectedPic = contentItem
                                                            showPic.toggle()
                                                        }
                                                } else {
                                                    Text(contentItem)
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .background(Color("LimeGreen"))
                                                        .cornerRadius(8)
                                                }
                                            }
                                        } else {
                                            HStack {
                                                if contentItem.lowercased().hasPrefix("https://firebasestorage"),
                                                   let url = URL(string: contentItem) {
                                                    WebImage(url: url)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 350 ,height: 200)
                                                        .clipped()
                                                        .contentShape(Rectangle())
                                                        .cornerRadius(10)
                                                        .onTapGesture {
                                                            viewModel.selectedPic = contentItem
                                                            showPic.toggle()
                                                        }
                                                }  else if contentItem.lowercased().hasPrefix("https"){
                                                    Link(contentItem, destination: URL(string: contentItem)!)
                                                        .foregroundColor(.black)
                                                        .padding()
                                                        .background(Color.white)
                                                        .cornerRadius(8)
                                                } else {
                                                    Text(contentItem)
                                                        .foregroundColor(.black)
                                                        .padding()
                                                        .background(Color.white)
                                                        .cornerRadius(8)
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding([.horizontal, .top], 6)
                                }
                            }
                            
                            HStack{
                                Spacer()
                            }
                            .id("empty")
                            .onChange(of: viewModel.chatMessages) { _, _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo("empty", anchor: .bottom)
                                    }
                                }
                                viewModel.markMessagesAsRead(toId: viewModel.chatUser?.id ?? "")
                            }
                        }
                        
                    }
                    .background(Color.gray.opacity(0.1))
                    .scrollIndicators(.hidden)
                    if let selectedImage = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(10)
                                .padding()
                            
                            Button(action: {
                                self.selectedImage = nil
                                self.selectedItem = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .offset(x: -5, y: 5)
                        }
                    }
                    
                    HStack(spacing: 16){
                        
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 28))
                            .foregroundColor(Color("LimeGreen"))
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
                            .photosPicker(
                                isPresented: $showImagePicker,
                                selection: $selectedItem,
                                matching: .images
                            )
                            .onChange(of: selectedItem) { _ , newItem in
                                Task { @MainActor in
                                    if let newItem,
                                       let data = try? await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        self.selectedImage = uiImage
                                        print("Updated selectedImage: \(uiImage)")
                                    }
                                }
                            }
                        
                        ZStack{
                            Text("TypeMessage".localized(using: currentLanguage))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity,alignment: .leading)
                            TextEditor(text: $viewModel.chatText)
                                .frame(height: 25)
                                .opacity(viewModel.chatText.isEmpty ? 0.5 : 1)
                        }
                        
                        Button{
                            let trimmedText = viewModel.chatText.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if let image = selectedImage {
                                self.selectedImage = nil
                                self.selectedItem = nil
                                viewModel.chatText = ""
                                PhotoUploaderManager.shared.uploadImages(image: image, isPost: false) { result in
                                    switch result {
                                    case .success(let url):
                                        let contentArray = [trimmedText, url.absoluteString].filter { !$0.isEmpty }
                                        viewModel.handleSendMessage(content: contentArray)
                                    case .failure(let error):
                                        print("Image upload failed: \(error.localizedDescription)")
                                    }
                                }
                            } else if !trimmedText.isEmpty {
                                viewModel.handleSendMessage(content: [trimmedText])
                                viewModel.chatText = ""
                            }
                            
                        } label: {
                            Text("Send".localized(using: currentLanguage))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(isDisabled ? .gray : Color("LimeGreen"))
                        .cornerRadius(8)
                        .disabled(isDisabled)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    
                }
                .navigationTitle(viewModel.chatUser?.username ?? "Chat")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.primary)
                            .onTapGesture{
                                dismiss()
                            }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        VStack{
                            if let chatUser = chatUser {
                                if chatUser.profileImage.isEmpty {
                                    Image("profile")
                                        .resizable()
                                } else if let imageURL = URL(string: chatUser.profileImage) {
                                    WebImage(url: imageURL)
                                        .resizable()
                                }
                            }
                        }
                        .frame(width: 35, height: 35)
                        .cornerRadius(50)
                        .background{
                            Circle()
                                .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                        }
                    }
                }
            }
            .onAppear{
                viewModel.markMessagesAsRead(toId: viewModel.chatUser?.id ?? "")
            }
            .onDisappear{
                viewModel.firestoreListener?.remove()
            }
            
            if showPic {
                if let pic = viewModel.selectedPic {
                    PicView(pic: pic, showPic: $showPic)
                }
            }
            
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
    
    var isDisabled: Bool {
        viewModel.chatText == "" && selectedImage == nil
    }
}
