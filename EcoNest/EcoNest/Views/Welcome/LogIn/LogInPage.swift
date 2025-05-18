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
    @State private var isLoggedIn = true
    @State private var isLoading = false
    @State private var goToHome = false
    @State private var goToForgot = false
    @State private var isConPasswordSecure: Bool = true
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var alertManager = AlertManager.shared
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack{
            ScrollView(.vertical){
                ZStack {
                    VStack{
                        if isLoggedIn {
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
                                CustomTextField(placeholder: "Name".localized(using: currentLanguage), text: $username, isSecure: .constant(false))
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
                                ZStack(alignment: .trailing) {
                                    CustomTextField(placeholder: "ConfirmPassword".localized(using: currentLanguage), text: $confirmPassword, isSecure: $isConPasswordSecure)
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
                                        authViewModel.signUp(name: username, email: email, password: password,confirmPassword: confirmPassword) { success, message in
                                            isLoading = false
                                            if success {
                                                authViewModel.savePasswordIfNeeded(account: email, newPassword: password)
                                                goToHome = true
                                            } else if let message = message {
                                                AlertManager.shared.showAlert(title: "Error".localized(using: currentLanguage), message: message)
                                            }
                                        }
                                    }
                                ).disabled(isLoading)
                                // Navigation to log in
                                HStack{
                                    Text("HaveAccount".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LimeGreen"):Color("DarkGreen"))
                                    Text("LogIn2".localized(using: currentLanguage))
                                        .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("LimeGreen"))
                                        .onTapGesture {
                                            isLoggedIn.toggle()
                                        }
                                }
                                
                            }.padding(.horizontal,30)
                        }
                    }
                    .padding(.top, 420)
                    //.frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height * 1.23)
                    
                    
                }
            }
            .background(CustomBackground())
            NavigationLink(
                destination: MainTabView(),
                isActive: $goToHome,
                label: {
                    EmptyView()
                }
            )
        }
    }
}
