//
//  File.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

@ViewBuilder
func UsersRow(user: User, image: String, receiveMessages: Bool) -> some View {
    HStack (alignment: .center){
        VStack{
            if image == "" {
                Image("profile")
                    .resizable()
            }  else if let imageURL = URL(string: image){
                WebImage(url: imageURL)
                    .resizable()
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(50)
        .background{
            Circle()
                .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
        }
        
        Text(user.username)
            .font(.headline)
        
        
        Spacer()
        
        if FirebaseManager.shared.auth.currentUser?.uid != user.id && receiveMessages {
            Text("chat")
                .bold()
                .foregroundColor(Color("LimeGreen"))
                .padding(.horizontal)
        }
            
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
}
