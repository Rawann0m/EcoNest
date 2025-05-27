//
//  LogInPage.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//

import SwiftUI

struct AuthViewPage: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email: String = ""
    @State private var Semail: String = ""
    @State private var password: String = ""
    @State private var Spassword: String = ""
    @State private var isPasswordSecure: Bool = true
    @State private var isLoggedIn = true
    @State private var isLoading = false
    @State private var goToHome = false
    @State private var goToForgot = false
    @State private var isConPasswordSecure: Bool = true
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
    @Environment(\.dismiss) var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var alertManager = AlertManager.shared
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack{
            GeometryReader{ geometry in
                ScrollView(.vertical){
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
                            Group{
                            Image(systemName:currentLanguage == "ar" ? "chevron.right":"chevron.left")
                                .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                                .offset(x:-170, y:-120)
                        }
                                .onTapGesture {
                                    dismiss()
                                }.accessibilityIdentifier("BackButton")
                                .accessibilityAddTraits(.isButton)
                                .accessibilityElement()
                        }.padding(.top,-62)
                        
                            .ignoresSafeArea(.all)
                        
                        
                        if isLoggedIn {
                            VStack(spacing: 20){
                                Text("LogIn".localized(using: currentLanguage))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                                    .padding(.bottom,20)
                                    .padding(.top,-15)
                                CustomTextField(placeholder: "Email".localized(using: currentLanguage), text: $email, isSecure: .constant(false)).accessibilityIdentifier("LoginEmail")
                                ZStack(alignment: .trailing) {
                                    CustomTextField(placeholder: "Password".localized(using: currentLanguage), text: $password, isSecure: $isPasswordSecure).accessibilityIdentifier("LoginPassword")
                                    Button(action: {
                                        isPasswordSecure.toggle()
                                    }) {
                                        Image(systemName: isPasswordSecure ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 16)
                                    }.accessibilityIdentifier("LoginTogglePasswordVisibility")
                                }
                                Button(action:{
                                    goToForgot = true
                                }){ Text("ForgotPassword".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } .accessibilityIdentifier("ForgotPasswordButton")
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
                                                    authViewModel.savePasswordIfNeeded(account: email, newPassword: password)
                                                    goToHome = true
                                                }else if let message = message {
                                                    AlertManager.shared.showAlert(title: "Error".localized(using: currentLanguage), message: message)
                                                }
                                            }
                                        }
                                    }
                                ).disabled(isLoading)
                                    .padding(.bottom)
                                    .accessibilityIdentifier("LoginButton")
                                // Navigation to log in
                                HStack{
                                    Text("DHaveAccount".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LimeGreen"):Color("DarkGreen"))
                                    Group{
                                    Text("SignUp2".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                }
                                        .onTapGesture {
                                            isLoggedIn.toggle()
                                        }
                                        .accessibilityIdentifier("SwitchToSignUp")
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityElement()
                                        
                                }
                                
                            }.padding(.horizontal,30)
                                .fullScreenCover(isPresented:$goToForgot){
                                    ForgotPasswordPage()
                                }
                        }
                        else{
                            VStack(spacing: 20){
                                Text("SignUp".localized(using: currentLanguage))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                                CustomTextField(placeholder: "Name".localized(using: currentLanguage), text: $username, isSecure: .constant(false)).accessibilityIdentifier("SignUpName")
                                CustomTextField(placeholder: "Email".localized(using: currentLanguage), text: $Semail, isSecure: .constant(false)).accessibilityIdentifier("SignUpEmail")
                                ZStack(alignment: .trailing) {
                                    CustomTextField(placeholder: "Password".localized(using: currentLanguage), text: $Spassword, isSecure: $isPasswordSecure).accessibilityIdentifier("SignUpPassword")
                                    Button(action: {
                                        isPasswordSecure.toggle()
                                    }) {
                                        Image(systemName: isPasswordSecure ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 16)
                                    }.accessibilityIdentifier("SignUpTogglePasswordVisibility")
                                }
                                ZStack(alignment: .trailing) {
                                    CustomTextField(placeholder: "ConfirmPassword".localized(using: currentLanguage), text: $confirmPassword, isSecure: $isConPasswordSecure) .accessibilityIdentifier("ConfirmPassword")
                                    Button(action: {
                                        isConPasswordSecure.toggle()
                                    }) {
                                        Image(systemName: isConPasswordSecure ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 16)
                                    }
                                }
                                
                                // Custom button
                                CustomButton(
                                    title: "SignUp".localized(using: currentLanguage),
                                    action: {
                                        // Check name
                                        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
                                            let message = "NameRequired".localized(using: currentLanguage)
                                            AlertManager.shared.showAlert(title: "Error".localized(using: currentLanguage), message: message)
                                            return
                                        }
                                        // Create User with Firebase
                                        isLoading = true
                                        authViewModel.signUp(name: username, email: Semail, password: Spassword,confirmPassword: confirmPassword) { success, message in
                                            isLoading = false
                                            if success {
                                                authViewModel.savePasswordIfNeeded(account: Semail, newPassword: Spassword)
                                                goToHome = true
                                            }
                                        }
                                    }
                                ).disabled(isLoading)
                                    .accessibilityIdentifier("SignUpButton")
                                // Navigation to log in
                                HStack{
                                    Text("HaveAccount".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LimeGreen"):Color("DarkGreen"))
                                    Group{
                                    Text("LogIn2".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                }
                                        .onTapGesture {
                                            isLoggedIn.toggle()
                                        }.accessibilityIdentifier("SwitchToLogin")
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityElement()
                                }
                                
                            }.padding(.horizontal,30)
                        }
                    }

                }
                NavigationLink(
                    destination: MainTabView(),
                    isActive: $goToHome,
                    label: {
                        EmptyView()
                    }
                )
            }
        } .alert(isPresented: $alertManager.alertState.isPresented) {
            Alert(
                title: Text(alertManager.alertState.title),
                message: Text(alertManager.alertState.message),
                dismissButton: .default(Text("OK"))
            )
        }
            .ignoresSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
