//
//  DirectMessageList.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct DirectMessageListView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State var showLogOutOptions: Bool = false
    @StateObject var viewModel = DirectMessageViewModel()
    @State private var selectedUser: User?
    
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
                                    selectedUser = User(id: uid, username: message.username, email: "", profileImage: message.profileImage ?? "")
                                }
                        }
                        .onDelete(perform: viewModel.DeleteMessage)
                    }
                    .listStyle(.plain)
                    .padding(0)
                }
        }
        .fullScreenCover(item: $selectedUser) { user in
            ChatView(chatUser: user)
        }
        .onDisappear{
            viewModel.firestoreListener?.remove()
        }
    }
}
