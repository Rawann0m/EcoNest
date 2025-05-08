//
//  File.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI

@ViewBuilder
func UsersRow(username: String, email: String, image: String, time: String, message: String) -> some View {
    @EnvironmentObject var themeManager: ThemeManager
    HStack {
        Image(image.isEmpty ? "profile" : image)
            .resizable()
            .frame(width: 60, height: 60)
            .cornerRadius(50)
            .background{
                Circle()
                    .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
            }
        
        VStack(alignment: .leading) {
            
            HStack{
                Text(username)
                    .font(.headline)
                
                Spacer()
                
                Text(time)
                    .font(.caption)
            }
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        Spacer()
    }
    .padding(11)
}
