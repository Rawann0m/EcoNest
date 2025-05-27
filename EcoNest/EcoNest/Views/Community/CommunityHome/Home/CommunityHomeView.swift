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
    @ObservedObject var communityViewModel: CommunityViewModel
    @StateObject var viewModel: PostsListViewModel
    @StateObject var memberViewModel: MembersListViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State var isLoading: Bool = false
    init(communityViewModel: CommunityViewModel){
        self.communityViewModel = communityViewModel
        _viewModel = StateObject(wrappedValue: PostsListViewModel(communityId: communityViewModel.selectedCommunity?.id ?? ""))
        _memberViewModel = StateObject(wrappedValue:(MembersListViewModel(members: communityViewModel.selectedCommunity?.members ?? [])))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing){
                if let community = communityViewModel.selectedCommunity{
                ScrollView {
                        VStack(spacing: 0) {
                            Image("community")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                                .overlay(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(themeManager.isDarkMode ? .black : .white)
                                        .frame(height: 50)
                                        .offset(y: 20)
                                }
                            
                            VStack {
                                HStack {
                                    Text(currentLanguage == "en" ? community.name[0] : community.name[1])
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text(community.memberOfCommunity ? "Leave".localized(using: currentLanguage): "Join".localized(using: currentLanguage))
                                        .frame(width: 70)
                                        .foregroundColor(.black)
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
                                                        
                                                        communityViewModel.removeUserIDFromMembers(communityId: communityId, userId: userId)
                                                        
                                                        
                                                        if var updatedCommunity = communityViewModel.selectedCommunity {
                                                            updatedCommunity.memberOfCommunity = false
                                                            updatedCommunity.members.removeAll { $0 == userId }
                                                            communityViewModel.selectedCommunity = updatedCommunity
                                                        }
                                                    }
                                                } else {
                                                    if let userId = FirebaseManager.shared.auth.currentUser?.uid, let communityId = community.id{
                                                        
                                                        communityViewModel.addUserIDToMembers(communityId: communityId, userId: userId)
                                                        
                                                        
                                                        if var updatedCommunity = communityViewModel.selectedCommunity {
                                                            updatedCommunity.memberOfCommunity = true
                                                            updatedCommunity.members.append( userId)
                                                            communityViewModel.selectedCommunity = updatedCommunity
                                                        }
                                                    }
                                                }
                                            } else {
                                                AlertManager.shared.showAlert(title: "Alert".localized(using: currentLanguage), message: "YouNeedToLoginFirst".localized(using: currentLanguage))
                                            }
                                        }
                                }
                                .padding(.horizontal)
                                .padding(.top, 35)
                                
                                HStack (spacing: 5) {
                                    Image(systemName: "person.and.person.fill")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    
                                    Group {
                                        if community.members.count == 1 {
                                            Text(String(format: "memberCommunity".localized(using: currentLanguage), community.members.count))
                                        } else {
                                            Text(String(format: "membersCommunity".localized(using: currentLanguage), community.members.count))
                                        }
                                    }
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                
                                Text(currentLanguage == "en" ? community.description[0] : community.description[1])
                                    .font(.caption)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Text("Posts".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? .white : (showPosts ? .white : .black))
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
                                        .foregroundColor(themeManager.isDarkMode ? .white : (!showPosts ? .white : .black))
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
                                    
                                    PostsListView(viewModel: viewModel, communityId: community.id ?? "", isLoading: $isLoading)
    
                                } else {
                                    MembersListView(members: communityViewModel.selectedCommunityMembers, viewModel: memberViewModel)
                                }
                            }
                            .padding(.top, -50)
                            
                            Spacer()
                            
                        }
                        .fullScreenCover(isPresented: $showCreatePost){
                            CreatePost(communityId: community.id ?? "", isLoading: $isLoading)
                        }
                    }
                    if showPosts && community.memberOfCommunity{
                        Button(action: {
                            if FirebaseManager.shared.isLoggedIn {
                                showCreatePost.toggle()
                            } else {
                                AlertManager.shared.showAlert(title: "Alert".localized(using: currentLanguage), message: "YouNeedToLoginFirst".localized(using: currentLanguage))
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
            }
            .alert(isPresented: $alertManager.alertState.isPresented) {
                Alert(
                    title: Text(alertManager.alertState.title),
                    message: Text(alertManager.alertState.message),
                    primaryButton: .default(Text("Login".localized(using: currentLanguage))) {
                        navigateToLogin = true
                    },
                    secondaryButton: .cancel(Text("Cancel".localized(using: currentLanguage)))
                )
            }
            .fullScreenCover(isPresented: $navigateToLogin) {
                AuthViewPage()
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                if let communityId = communityViewModel.selectedCommunity?.id {
                    communityViewModel.listenToSelectedCommunity(communityId: communityId)
                }
            }
            .onDisappear{
                viewModel.firestoreListener?.remove()
                viewModel.postRepliesListener?.remove()
                viewModel.selectedPostListener?.remove()
                viewModel.repliesListeners?.remove()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .bold()
                        .foregroundColor(.black)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}


