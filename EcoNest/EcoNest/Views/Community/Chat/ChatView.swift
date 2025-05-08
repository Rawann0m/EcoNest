//
//  Chat.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct ChatView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView{
                    ScrollViewReader{ proxy in
                        //viewModel.chatMessages
                        ForEach(0..<5){ message in
                            VStack{
                                //                            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                                //                                HStack{
                                //                                    Spacer()
                                //                                    HStack{
                                //                                        Text(message.text)
                                //                                            .foregroundColor(.white)
                                //                                    }
                                //                                    .padding()
                                //                                    .background(Color.blue)
                                //                                    .cornerRadius(8)
                                //                                }
                                //                            }
                                //                            else {
                                HStack{
                                    HStack{
                                        Text("message.text")
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    
                                    Spacer()
                                    // }
                                }
                            }.padding([.horizontal, .top])
                            
                        }
                        
                        HStack{
                            Spacer()
                        }
                        .id("empty")
                        //                    .onReceive(viewModel.$count) { _ in
                        //                        withAnimation(.easeInOut(duration: 0.5)) {
                        //                            proxy.scrollTo("empty", anchor: .bottom)
                        //                        }
                        //
                        //                    }
                    }
                    
                }
                .background(Color.gray.opacity(0.1))
                
                HStack(spacing: 16){
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(Color("LimeGreen"))
                    
                    ZStack{
                        Text("Type a message...")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity,alignment: .leading)
                        TextEditor(text: .constant("$viewModel.chatText"))
                            .frame(height: 25)
                            .opacity("viewModel.chatText".isEmpty ? 0.5 : 1)
                    }
                    
                    Button{
                        // viewModel.handleSendMessage()
                    } label: {
                        Text("Send".localized(using: currentLanguage))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color("LimeGreen"))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                
            }
            //        .navigationTitle(viewModel.chatUser?.username ?? "Chat")
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.primary)
                        .onTapGesture{
                            dismiss()
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image("profile")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .cornerRadius(50)
                        .background{
                            Circle()
                                .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                        }
                }
            }
        }
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
