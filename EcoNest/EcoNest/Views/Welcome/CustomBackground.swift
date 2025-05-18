//
//  CustomBackground.swift
//  EcoNest
//
//  Created by Rawan on 15/05/2025.
//

import SwiftUI

struct CustomBackground: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isLoggedIn = true
    @State private var isLoading = false
    @State private var goToHome = false
    @State private var goToForgot = false
    @Environment(\.dismiss) var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var alertManager = AlertManager.shared
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        GeometryReader{ geometry in
            NavigationStack{
                VStack{
                        ZStack{
                            //bubbles
                            Image("bubbles")
                                .resizable()
                                .frame(width: geometry.size.width * 1,height: geometry.size.width * 1)
                            //logo
                            Image(themeManager.isDarkMode ? "EcoNestL":"EcoNestG")
                                .resizable()
                                .frame(width: 230,height: 190)
                                .padding(.bottom,30)
                                .padding(.top , 45)
                            Image(systemName:currentLanguage == "ar" ? "chevron.right":"chevron.left")
                                .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                                .offset(x:-170, y:-120)
                                .onTapGesture {
                                    dismiss()
                                }
                        }
                        .ignoresSafeArea(.all)
                        ZStack{
                            CustomRoundedRectangle(topLeft: 90, topRight: 0, bottomLeft: 0, bottomRight: 0)
                                .fill(Color("LightGreen").opacity(0.4))
                                .frame(width: geometry.size.width * 1,height: geometry.size.width * 1.35)
                                .padding()
                                .edgesIgnoringSafeArea(.bottom)
                            
                        }
                        
                }
                .alert(isPresented: $alertManager.alertState.isPresented) {
                    Alert(
                        title: Text(alertManager.alertState.title),
                        message: Text(alertManager.alertState.message),
                        dismissButton: .default(Text("OK".localized(using: currentLanguage)))
                    )}
                .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}
