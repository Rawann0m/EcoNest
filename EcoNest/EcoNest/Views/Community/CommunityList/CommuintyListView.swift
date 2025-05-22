//
//  Commuinty.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct CommuintyListView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State var showCommunity: Bool = false
    @StateObject var communityViewModel = CommunityViewModel()
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    if communityViewModel.isLoading {
                        ProgressView()
                            .frame(height: 500, alignment: .center)
                    } else {
                        ForEach(communityViewModel.communities, id: \.self){ community in
                            ZStack{
                                Image("community")
                                    .resizable()
                                    .frame(width: 350, height: 250)
                                    .cornerRadius(10)
                                
                                VStack{
                                    Group{
                                        Text(currentLanguage == "en" ? community.name[0] : community.name[1])
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .bold()
                                            .frame(width: 320, alignment: .leading)
                                        
//                                        Text("\(community.members.count) members".localized(using: currentLanguage))
                                        Text("\(community.members.count) \(Text("membersCommunity"))")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .bold()
                                            .frame(width: 320, alignment: .leading)
                                    }
                                    .offset(y: community.memberOfCommunity ? 75 : 50)
                                    
                                    if !community.memberOfCommunity {
                                        Text("JoinNow".localized(using: currentLanguage))
                                            .foregroundColor(.black)
                                            .background{
                                                Capsule()
                                                    .fill(.white)
                                                    .frame(width: 320, height: 50)
                                            }
                                            .frame(width: 320, height: 50)
                                            .offset(y: 50)
                                            .onTapGesture {
                                                if FirebaseManager.shared.isLoggedIn {
                                                    
                                                    if let userId = FirebaseManager.shared.auth.currentUser?.uid, let communityId = community.id{
                                                        
                                                        communityViewModel.addUserIDToMembers(communityId: communityId, userId: userId)
                                                    }
                                                    
                                                } else {
                                                    AlertManager.shared.showAlert(title: "Error", message: "You need to login first!")
                                                }
                                            }
                                    }
                                }
                            }
                            .onTapGesture {
                                communityViewModel.selectedCommunity = community
                                showCommunity.toggle()
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear{
                communityViewModel.fetchCommunities()
            }
            .onDisappear{
                communityViewModel.communityListener?.remove()
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
        .fullScreenCover(isPresented: $showCommunity) {
            CommunityHomeView(communityViewModel: communityViewModel)
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            LogInPage()
        }
    }
}

