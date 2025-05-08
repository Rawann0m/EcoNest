//
//  CommunityAndMessagesView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//
import SwiftUI

struct CommunityAndMessagesView: View {
    @State var isCommunity: Bool = true
    @Namespace var namespace
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Community".localized(using: currentLanguage))
                        .foregroundColor(isCommunity ? .white : .black)
                        .frame(width: 170, height: 50, alignment: .center)
                        .background {
                            if isCommunity {
                                Capsule()
                                    .fill(Color("LimeGreen"))
                                    .matchedGeometryEffect(id: "Type", in: namespace)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isCommunity = true
                            }
                        }
                        .frame(maxWidth: 200)

                    Text("DirectMessages".localized(using: currentLanguage))
                        .foregroundColor(!isCommunity ? .white : .black)
                        .frame(width: 170, height: 50, alignment: .center)
                        .background {
                            if !isCommunity {
                                Capsule()
                                    .fill(Color("LimeGreen"))
                                    .matchedGeometryEffect(id: "Type", in: namespace)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isCommunity = false
                            }
                        }
                        .frame(maxWidth: 200)
                }
                
                if isCommunity {
                    CommuintyListView()
                        .padding()
                } else {
                    DirectMessageListView()
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle(isCommunity ? "Community".localized(using: currentLanguage) : "DirectMessages".localized(using: currentLanguage))
        }
    }
}
