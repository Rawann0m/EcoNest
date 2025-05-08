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
    @ObservedObject var communityViewModel = CommunityListViewModel()
    @StateObject var alertManager = AlertManager.shared
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationStack {
            VStack{
                ForEach(communityViewModel.communities, id: \.self){ community in
                    ZStack{
                        Image("community")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .cornerRadius(10)
                        
                        VStack{
                            Group{
                                Text(community.name)
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(width: 320, alignment: .leading)
                                
                                Text("\(community.members.count) members")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(width: 320, alignment: .leading)
                            }
                            .offset(y: 50)
                            
                            Text("JoinNow".localized(using: currentLanguage))
                                .background{
                                    Capsule()
                                        .fill(.white)
                                        .frame(width: 320, height: 50)
                                }
                                .frame(width: 320, height: 50)
                                .offset(y: 50)
                                .onTapGesture {
                                    if FirebaseManager.shared.isLoggedIn {
                                        // add user to community
                                    } else {
                                        AlertManager.shared.showAlert(title: "Error", message: "You need to login first!")
                                    }
                                }
                        }
                    }
                    .onTapGesture {
                        communityViewModel.selectedCommunity = community
                       // if communityViewModel.selectedCommunity != nil {
                            showCommunity.toggle()
                      //  }
                    }
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
        }
        .fullScreenCover(isPresented: $showCommunity) {
            if let community = communityViewModel.selectedCommunity {
                CommunityHomeView(community: community)
            }
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            LogInPage()
        }
    }
}

