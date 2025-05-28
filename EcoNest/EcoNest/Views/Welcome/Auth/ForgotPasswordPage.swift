//
//  ForgotPasswordPage.swift
//  EcoNest
//
//  Created by Rawan on 07/05/2025.
//
import SwiftUI

struct ForgotPasswordPage:View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email: String = ""
    @State private var isLoading = false
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var alertManager = AlertManager.shared
    @Environment(\.dismiss) var dismiss
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    var body: some View {
        NavigationStack{
            GeometryReader{ geometry in
            VStack{
                ScrollView(.vertical) {
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
                    }.padding(.top,-62)
                    
                    
                    VStack(spacing: 20){
                        Text("ResetPassword".localized(using: currentLanguage))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.isDarkMode ? Color("LightGreen"):Color("DarkGreen"))
                            .accessibilityIdentifier("ResetPasswordTitle")
                        CustomTextField(placeholder: "Email".localized(using: currentLanguage), text: $email, isSecure: .constant(false))
                        // Custom button
                        CustomButton(
                            title: "Send".localized(using: currentLanguage),
                            action: {
                                authViewModel.resetPasswordWithEmailLookup(for: email)
                            }
                        )
                        .disabled(isLoading)
                    }.padding(.horizontal,30)
                        .padding(.top,70)
                }
            }
        }
            }.alert(isPresented: $alertManager.alertState.isPresented) {
            Alert(
                title: Text(alertManager.alertState.title),
                message: Text(alertManager.alertState.message),
                dismissButton: .default(Text("OK".localized(using: currentLanguage)))
            )}
        .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
