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
     
    var body: some View {
        VStack{
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 300, alignment: .center)
            } else{
                if viewModel.members.isEmpty {
                    Text("No members found")
                        .frame(height: 300, alignment: .center)
                } else {
                    ScrollViewReader{ scrollProxy in
                        LazyVStack{
                            ForEach(viewModel.members){ member in
                                UsersRow(username: member.username, email: member.email, image: member.profileImage, time: "", message: "")
                                    .id(member.id)
                                    .onAppear {
                                        savedId = member.id
                                    }
                                    .onTapGesture {
                                        if FirebaseManager.shared.isLoggedIn {
                                            showChat.toggle()
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
            ChatView()
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
}
