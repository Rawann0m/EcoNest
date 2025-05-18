//
//  DirectMessageList.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct DirectMessageListView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State var showChat: Bool = false
    @State var showLogOutOptions: Bool = false
    @StateObject var viewModel = DirectMessageViewModel()
    
    var body: some View {
        NavigationStack{
           
                if viewModel.recentMessages.isEmpty {
                    Text("No messages yet")
                        .frame(height: 500)
                } else {
                    List {
                        ForEach(viewModel.recentMessages){ message in
                            UsersRow(username: message.username, email: "", image: message.profileImage ?? "", time: message.timeAgo, message: message.content[0])
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    let uid = FirebaseManager.shared.auth.currentUser!.uid == message.fromId ? message.toId : message.fromId
                                    viewModel.user = User(id: uid, username: message.username, email: "", profileImage: message.profileImage ?? "")
                                    showChat.toggle()
                                }
                        }
                        .onDelete(perform: viewModel.DeleteMessage)
                        //}
                        
                    }
                    .listStyle(.plain)
                    .padding(0)
                }
        }
        .fullScreenCover(isPresented: $showChat) {
            ChatView(chatUser: viewModel.user)
        }
        .onDisappear{
            viewModel.firestoreListener?.remove()
        }
    }
}
