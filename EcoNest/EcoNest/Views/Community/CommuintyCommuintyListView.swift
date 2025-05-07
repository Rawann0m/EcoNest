//
//  Commuinty.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 08/11/1446 AH.
//

import SwiftUI

struct CommuintyListView: View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack {
            VStack{
                ForEach(0..<2){_ in
                    ZStack{
                        Image("community")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .cornerRadius(10)
                        
                        VStack{
                            
                            Group{
                                Text("GrowMete")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(width: 320, alignment: .leading)
                                
                                Text("123 members")
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
                        }
                    }
                }
            }
        }
    }
}

