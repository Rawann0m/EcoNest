//
//  Commuinty.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct CommuintyListView: View {
    // MARK: - variabels
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State var showCommunity: Bool = false
    @StateObject var communityViewModel = CommunityViewModel()
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    @EnvironmentObject var themeManager: ThemeManager
    // MARK: - UI Design
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
                                            .background(.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
                                            .bold()
                                            .frame(width: 320, alignment: .leading)
                                        
                                        Group {
                                            if community.members.count == 1 {
                                                Text(String(format: "memberCommunity".localized(using: currentLanguage), community.members.count))
                                            } else {
                                                Text(String(format: "membersCommunity".localized(using: currentLanguage), community.members.count))
                                            }
                                        }
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(.gray.opacity(0.2))
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
                                                    AlertManager.shared.showAlert(title: "Alert".localized(using: currentLanguage), message: "YouNeedToLoginFirst".localized(using: currentLanguage))
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
            .scrollIndicators(.hidden)
            .onDisappear{
                communityViewModel.communityListener?.remove()
            }
        }
        .fullScreenCover(isPresented: $showCommunity) {
            CommunityHomeView(communityViewModel: communityViewModel)
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            AuthViewPage()
        }
    }
}

