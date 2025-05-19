//
//  MembersListView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 10/11/1446 AH.
//

import SwiftUI

struct MembersListView: View {
    @State var showChat: Bool = false
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    var members: [String] = []
    @ObservedObject var viewModel: MembersListViewModel
    @State private var savedId: String?
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        VStack{
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 300, alignment: .center)
            } else{
                if viewModel.members.isEmpty {
                    Text("Nomembersfound".localized(using: currentLanguage))
                        .frame(height: 300, alignment: .center)
                } else {
                    ScrollViewReader{ scrollProxy in
                        LazyVStack{
                            // Text field for user input
                            TextField("Search", text: $viewModel.searchText)
                                .padding(12)
                                .background(.gray.opacity(0.1), in: .rect(cornerRadius: 25))
                                .foregroundColor(.gray)
                                .frame(height: 25)
                                .padding()
                                .disableAutocorrection(true) // Prevent autocorrect suggestions
                                .textInputAutocapitalization(.none) // Disable auto-capitalization for accurate search matching
                            
                            ForEach(getMembers()){ member in
                                UsersRow(username: member.username, email: member.email, image: member.profileImage, time: "", message: "")
                                    .id(member.id)
                                    .onAppear {
                                        savedId = member.id
                                    }
                                    .onTapGesture {
                                        if FirebaseManager.shared.isLoggedIn{
                                            viewModel.selectedMember = member
                                            if  member.id != FirebaseManager.shared.auth.currentUser?.uid{
                                                showChat.toggle()
                                            }
                                        } else {
                                            AlertManager.shared.showAlert(title: "Error", message: "You need to login first!")
                                        }
                                    }
                            }
                        }
                        .onAppear {
                            if let id = savedId {
                                scrollProxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showChat) {
            ChatView(chatUser: viewModel.selectedMember )
        }
        .alert(isPresented: $alertManager.alertState.isPresented) {
            Alert(
                title: Text(alertManager.alertState.title),
                message: Text(alertManager.alertState.message),
                primaryButton: .default(Text("Login")) {
                    navigateToLogin = true
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func getMembers() -> [User]{
        if viewModel.searchText.isEmpty {
            return viewModel.members
        } else {
            return viewModel.members.filter { $0.username.lowercased().contains(viewModel.searchText.lowercased()) }
        }
    }
}
