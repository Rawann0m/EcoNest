//
//  WelcomePage.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//
import SwiftUI

struct WelcomePage: View {
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        NavigationStack{
            ZStack{
                //background
                Image("BG")
                    .resizable()
                    .ignoresSafeArea()
                VStack{
                    //logo
                Image("EcoNestW")
                    .resizable()
                    .frame(width: 260,height: 210)
                    .padding(.bottom,30)
                    .padding(.top , 45)
                    //welcome message
                Text("Welcome to EcoNest ")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                    Text("Where every plant finds its perfect home.")
                        .font(.headline)
                        .lineLimit(3)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom,70)
                    
                    Spacer()
                    //auth buttons
                AuthButton(label: "Log in")
                        .padding(.bottom,15)
                AuthButton(label: "Sign up")
                        .padding(.bottom, 100)
            }
                
            }
        }
    }
}
