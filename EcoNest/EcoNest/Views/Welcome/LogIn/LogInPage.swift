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
    @State private var goToHome = false
    @State private var goToForgot = false
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var alertManager = AlertManager.shared
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.vertical) {
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
                    Image(systemName:currentLanguage == "ar" ? "chevron.right":"chevron.left")
                        .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                        .offset(x:-170, y:-120)
                        .onTapGesture {
                            goToHome = true
                        }
                }
                .padding(.top,-50)
                ZStack{
                    CustomRoundedRectangle(topLeft: 90, topRight: 0, bottomLeft: 0, bottomRight: 0)
                        .fill(Color("LightGreen").opacity(0.4))
                        .frame(width: 400,height: 550)
                        .padding()
                        .edgesIgnoringSafeArea(.bottom)
                    
                        VStack(spacing: 20){
                            Text("LogIn".localized(using: currentLanguage))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                                .padding(.bottom,20)
                                .padding(.top,-15)
                            CustomTextField(placeholder: "Email".localized(using: currentLanguage), text: $email, isSecure: .constant(false))
                            ZStack(alignment: .trailing) {
                                CustomTextField(placeholder: "Password".localized(using: currentLanguage), text: $password, isSecure: $isPasswordSecure)
                                Button(action: {
                                    isPasswordSecure.toggle()
                                }) {
                                    Image(systemName: isPasswordSecure ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 16)
                                }
                            }
                            Button(action:{
                                goToForgot = true
                            }){ Text("ForgotPassword".localized(using: currentLanguage))
                                    .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            // Custom button
                            CustomButton(
                                title: "LogIn".localized(using: currentLanguage),
                                action: {
                                    DispatchQueue.main.async {
                                        isLoading = true
                                        // Firebase login
                                        authViewModel.logIn(email: email, password: password) { success, message in
                                            isLoading = false
                                            if success {
                                                goToHome = true
                                                print("go home")
                                            }else if let message = message {
                                                AlertManager.shared.showAlert(title: "Error".localized(using: currentLanguage), message: message)
                                            }
                                        }
                                    }
                                }
                            ).disabled(isLoading)
                                .padding(.bottom)
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
                            //.padding(.top)
                }.padding(.bottom,-60)
                }
                
            }.fullScreenCover(isPresented:$goToForgot){
                ForgotPasswordPage()
            }
            NavigationLink(
                destination: SignUpPage(),
                        isActive: $isLoggedIn,
                        label: {
                            EmptyView()
                        }
            )
            NavigationLink(
                destination: MainTabView(),
                        isActive: $goToHome,
                        label: {
                            EmptyView()
                        }
                    )
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

