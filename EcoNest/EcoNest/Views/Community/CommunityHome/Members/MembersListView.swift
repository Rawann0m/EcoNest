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
    @StateObject var viewModel = MembersListViewModel()
    var body: some View {
        VStack{
            if viewModel.members.isEmpty {
                Text("No members found")
                    .frame(height: 300, alignment: .center)
            } else {
                ForEach(viewModel.members){ member in
                    UsersRow(username: member.username, email: member.email, image: member.profileImage, time: "", message: "")
                        .onTapGesture {
                            if FirebaseManager.shared.isLoggedIn {
                                showChat.toggle()
                            } else {
                                AlertManager.shared.showAlert(title: "Error", message: "You need to login first!")
                            }
                        }
                }
            }
        }
        .onAppear {
            viewModel.fetchMembers(members: members)
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

#Preview {
    MembersListView()
}
