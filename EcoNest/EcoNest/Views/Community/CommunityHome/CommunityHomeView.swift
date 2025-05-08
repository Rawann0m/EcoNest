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
                                Text("GrowMate")
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                                
                                Text("Join")
                                    .frame(width: 70)
                                    .padding()
                                    .bold()
                                    .background {
                                        Capsule()
                                            .fill(Color("LightGreen"))
                                    }
                                    .onTapGesture {
                                        if FirebaseManager.shared.isLoggedIn {
                                            // add user to community
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
                                
                                Text("123 members")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            Text("Welcome to GrowMate — where plant lovers grow together!Discover, share tips, and get inspired as you care for your green companions with a community that roots for you. 🌿")
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
                                PostsListView()
                            } else {
                                MembersListView()
                            }
                        }
                        .padding(.top, -50)
                        
                        Spacer()
                    }
                    .fullScreenCover(isPresented: $showCreatePost){
                        CreatePost()
                    }
                }
                
                if showPosts {
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

#Preview {
    CommunityHomeView()
}


