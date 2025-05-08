//
//  Posts.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI

@ViewBuilder
func Post(text: String) -> some View {
    @EnvironmentObject var themeManager: ThemeManager
    VStack(alignment: .leading) {
        HStack(spacing: 16){
            Image("profile")
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(50)
                .background{
                    Circle()
                        .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                }
            
            VStack(alignment: .leading){
                Text("username")
                Text("date")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
    }
    .padding()
    .background{
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .stroke(.gray.opacity(0.3), lineWidth: 1)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
            .frame(maxWidth: .infinity)
    }
}
