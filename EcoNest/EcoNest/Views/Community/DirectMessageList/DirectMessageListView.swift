//
//  DirectMessageList.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct DirectMessageListView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State var showChat: Bool = false
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach(0..<7){ int in
                    UsersRow(username: "user \(int)", email: "", image: "", time: "", message: "")
                    .onTapGesture {
                        showChat.toggle()
                    }
                }
            }
            .padding(.bottom)
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showChat) {
            ChatView()
        }
    }
}
