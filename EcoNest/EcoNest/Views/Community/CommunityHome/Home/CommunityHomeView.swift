//
//  CommunityHomeView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//
//

import SwiftUI
struct CommunityHomeView: View {
    @State var showPosts: Bool = true
    @Namespace var namespace
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.dismiss) var dismiss
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    @State var showCreatePost: Bool = false
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    var community: Community
    @ObservedObject var communityViewModel = CommunityListViewModel()
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing){
                ScrollView {
                    VStack(spacing: 0) {
                        Image("community")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                            .overlay(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white)
                                    .frame(height: 50)
                                    .offset(y: 20)
                            }
                        
                        VStack {
                            HStack {
                                Text(community.name)
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                                
                                Text(community.memberOfCommunity ? "Leave": "Join")
                                    .frame(width: 70)
                                    .padding()
                                    .bold()
                                    .background {
                                        Capsule()
                                            .fill(Color("LightGreen"))
                                    }
                                    .onTapGesture {
                                        if FirebaseManager.shared.isLoggedIn {
                                            if community.memberOfCommunity {
                                                if let userId = FirebaseManager.shared.auth.currentUser?.uid, let communityId = community.id{
                                                    
                                                    communityViewModel.removeUserIDToMembers(communityId: communityId, userId: userId)
                                                    
                                                    communityViewModel.setMemberStatus(communityId: communityId, isMember: false)
                                                }
                                            } else {
                                                if let userId = FirebaseManager.shared.auth.currentUser?.uid, let communityId = community.id{
                                                    
                                                    communityViewModel.addUserIDToMembers(communityId: communityId, userId: userId)
                                                    
                                                    communityViewModel.setMemberStatus(communityId: communityId, isMember: true)
                                                }
                                            }
                                        } else {
                                            AlertManager.shared.showAlert(title: "Error", message: "You need to login first!")
                                        }
                                    }
                            }
                            .padding(.horizontal)
                            .padding(.top, 35)
                            
                            HStack (spacing: 5) {
                                Image(systemName: "person.and.person.fill")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                
                                Text("\(community.members.count) members")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            Text(community.description)
                                .font(.caption)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("Posts".localized(using: currentLanguage))
                                    .foregroundColor(showPosts ? .white : .black)
                                    .frame(width: 170, height: 50, alignment: .center)
                                    .background {
                                        if showPosts {
                                            Capsule()
                                                .fill(Color("LimeGreen"))
                                                .matchedGeometryEffect(id: "Type", in: namespace)
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            showPosts = true
                                        }
                                    }
                                    .frame(maxWidth: 200)
                                
                                Text("Members".localized(using: currentLanguage))
                                    .foregroundColor(!showPosts ? .white : .black)
                                    .frame(width: 170, height: 50, alignment: .center)
                                    .background {
                                        if !showPosts {
                                            Capsule()
                                                .fill(Color("LimeGreen"))
                                                .matchedGeometryEffect(id: "Type", in: namespace)
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            showPosts = false
                                        }
                                    }
                                    .frame(maxWidth: 200)
                            }
                            
                            if showPosts {
                                PostsListView(communityId: community.id ?? "")
                            } else {
                                MembersListView(members: community.members)
                            }
                        }
                        .padding(.top, -50)
                        
                        Spacer()
                    }
                    .fullScreenCover(isPresented: $showCreatePost){
                        CreatePost()
                    }
                }
                
                if showPosts && community.memberOfCommunity{
                    Button(action: {
                        if FirebaseManager.shared.isLoggedIn {
                            showCreatePost.toggle()
                        } else {
                            AlertManager.shared.showAlert(title: "Error", message: "You need to login first!")
                        }
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color("LimeGreen"))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        
                    }
                    .padding()
                }
                
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
            .fullScreenCover(isPresented: $navigateToLogin) {
                LogInPage()
            }
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .bold()
                        .foregroundColor(.primary)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
    }
}


