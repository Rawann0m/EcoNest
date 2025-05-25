//
//  File.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI

@ViewBuilder
func settingRow(icon: String, text: String, function: (() -> Void)? = nil, trailingView: () -> some View = { EmptyView() }, color: Color) -> some View {
    HStack(spacing: 16) {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("LimeGreen").opacity(0.3))
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(Color("LimeGreen"))
        }
        
        Text(text)
            .bold()
            .foregroundColor(color)
        
        Spacer()
    
        trailingView()
        
    }
    .padding(.horizontal)
    .frame(width: 350, height: 60)
    .background{
        RoundedRectangle(cornerRadius: 10)
            .stroke(.gray.opacity(0.3), lineWidth: 2)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
    }
    .onTapGesture {
        if let function = function {
            function()
        }
    }
}
