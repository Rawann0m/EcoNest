//
//  DirectMessageList.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct DirectMessageList: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State var showChat: Bool = false
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach(0..<7){ _ in
                    HStack {
                        Image("profile")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(50)
                            .background{
                                Circle()
                                    .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                            }
                        
                        VStack(alignment: .leading) {
                            
                            HStack{
                                Text("Rayaheen Mseri")
                                    .font(.headline)
                                Spacer()
                                Text("12:00 AM")
                                    .font(.caption)
                            }
                            Text("last Message")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(11)
                    .onTapGesture {
                        showChat.toggle()
                    }
                }
            }
            .padding(.bottom)
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showChat) {
            Chat()
        }
    }
}
