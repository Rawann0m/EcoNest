//
//  LogInPage.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//

import SwiftUI

struct LogInPage: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordSecure: Bool = true
    @State private var isLoggedIn = false
    @State private var isLoading = false
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    //bubbles
                    Image("bubbles")
                        .resizable()
                        .frame(width: 400,height: 400)
                    //logo
                    Image(themeManager.isDarkMode ? "EcoNestL":"EcoNestG")
                        .resizable()
                        .frame(width: 230,height: 190)
                        .padding(.bottom,30)
                        .padding(.top , 45)
                }.padding(.top)
                ZStack{
                    CustomRoundedRectangle(topLeft: 90, topRight: 0, bottomLeft: 0, bottomRight: 0)
                        .fill(Color("LightGreen").opacity(0.4))
                        .frame(width: 400,height: 550)
                        .padding()
                        .edgesIgnoringSafeArea(.bottom)
                    ScrollView(.vertical) {
                        VStack(spacing: 20){
                            Text("Log in")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                                .padding(.bottom,20)
                            CustomTextField(placeholder: "Email", text: $email, isSecure: .constant(false))
                            ZStack(alignment: .trailing) {
                                CustomTextField(placeholder: "Password", text: $password, isSecure: $isPasswordSecure)
                                Button(action: {
                                    isPasswordSecure.toggle()
                                }) {
                                    Image(systemName: isPasswordSecure ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                            }
                            Button("Forgot Password?"){
                                
                            }.foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                .padding(.leading,230)
                            
                            // Custom button
                            CustomButton(
                                title: "LogIn".localized(using: currentLanguage),
                                action: {
                                    
                                }
                            ).disabled(isLoading)
                                .padding(.bottom,60)
                            // Navigation to log in
                            HStack{
                                Text("DHaveAccount".localized(using: currentLanguage))
                                    .foregroundColor(themeManager.isDarkMode ? Color("LimeGreen"):Color("DarkGreen"))
                                Text("SignUp2".localized(using: currentLanguage))
                                    .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                    .onTapGesture {
                                        isLoggedIn.toggle()
                                    }
                            }
                            
                        }.padding(.horizontal,30)
                            .padding(.top,30)
                    }.padding(.top)
                }
                
            }
            .navigationBarBackButtonHidden(true)
            NavigationLink(
                destination: SignUpPage(),
                isActive: $isLoggedIn,
                label: {
                    EmptyView()
                }
            )
        }
    }
}

