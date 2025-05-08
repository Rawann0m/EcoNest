//
//  SignUpPage.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//

import SwiftUI

struct SignUpPage:View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordSecure: Bool = true
    @State private var isConPasswordSecure: Bool = true
    @State private var isLoggedIn = false
    @State private var isLoading = false
    @State private var goToHome = false
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var alertManager = AlertManager.shared
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
                            Text("Sign up")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                            CustomTextField(placeholder: "Name", text: $username, isSecure: .constant(false))
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
                            ZStack(alignment: .trailing) {
                                CustomTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: $isConPasswordSecure)
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
                    }.padding(.top)
                }
                
            }
            NavigationLink(
                destination: MainTabView(),
                isActive: $goToHome,
                label: {
                    EmptyView()
                }
            )
            NavigationLink(
                destination: LogInPage(),
                isActive: $isLoggedIn,
                label: {
                    EmptyView()
                }
            )
        }.alert(isPresented: $alertManager.alertState.isPresented) {
            Alert(
                title: Text(alertManager.alertState.title),
                message: Text(alertManager.alertState.message),
                dismissButton: .default(Text("OK".localized(using: currentLanguage)))
            )}
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        .navigationBarBackButtonHidden(true)

    }
}
