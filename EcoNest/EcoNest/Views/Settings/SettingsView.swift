//
//  Settings.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 07/11/1446 AH.
//

import SwiftUI

struct SettingsView: View {
    @State var isEdit: Bool = false
    @State private var isArabic: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var selectedLanguageIndex: Int = 0
    @Environment(\.openURL) var openURL
    @State var name: String = "Rayaheen Mseri"
    @State var isLogin = FirebaseManager.shared.auth.currentUser?.uid == nil
    var body: some View {
        NavigationStack{
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color("LimeGreen"))
                        .frame(height: 200)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2)  , radius: 10)
                        .frame(width: 350, height: 135)
                        .offset(y: 100)
                    
                    // check if there is no profuile image put this
                    Image("profile")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(50)
                        .background{
                            Circle()
                                .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
                        }
                        .offset(y: 30)
                    
                    
                   if isEdit {
                        ZStack {
                            Circle()
                                .fill(Color("DarkGreen"))
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "camera")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                        }
                        .offset(x: 30 ,y: 60)
                    }
                    
                    if FirebaseManager.shared.isLoggedIn {
                        Image(systemName: isEdit ? "checkmark" : "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("DarkGreen"))
                            .offset(x: 150, y: 50)
                            .onTapGesture {
                                isEdit.toggle()
                            }
                    }
                    
                    VStack(spacing: 10){
                        if isEdit{
                            TextField("Name", text: $name)
                                .frame(width: 200)
                                .multilineTextAlignment(.center)
                        } else {
                            TextField("Name", text: $name)
                                .frame(width: 200)
                                .multilineTextAlignment(.center)
                                .disabled(true)
                        }
                        
                        Text("Rayaheen@gmail.com")
                            .frame(width: 200)
                    }
                    .offset(y: 110)
                    
                }
                .ignoresSafeArea(.all)
                
                Text("General".localized(using: currentLanguage))
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                    settingRow(icon: "cart", text: "Orders".localized(using: currentLanguage), trailingView: {
                        NavigationLink{
                          // go to orders page
                            Text("orders")
                        } label:{
                            Image(systemName: currentLanguage == "ar" ? "chevron.left"  : "chevron.right")
                                .foregroundColor(Color("LimeGreen"))
                        }
                    })
                
                
                settingRow(icon: "globe", text: "Language".localized(using: currentLanguage), trailingView: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 40)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.isDarkMode ? .white : Color("LimeGreen"))
                            .frame(width: 60, height: 40)
                            .offset(x: isArabic ? -30 : 30)
                            .animation(.easeInOut(duration: 0.3), value: isArabic)
                        
                        HStack {
                            Text("AR")
                                .foregroundColor(isArabic ? themeManager.isDarkMode ? Color("LimeGreen") : .white : .gray)
                                .frame(maxWidth: .infinity)
                            
                            Text("EN")
                                .foregroundColor(isArabic ? .gray : themeManager.isDarkMode ? Color("LimeGreen") : .white)
                                .frame(maxWidth: .infinity)
                        }
                        .font(.subheadline)
                        .frame(width: 120, height: 40)
                        
                        
                    }
                    .onTapGesture {
                        isArabic.toggle()
                        
                    }
                })
                
                settingRow(icon: "sun.max", text: "DarkMode".localized(using: currentLanguage), function: {
                    // toggle dark mode
                    print("toggle dark mode")
                }, trailingView: {
                    Toggle("", isOn: $themeManager.isDarkMode)
                        .tint(Color("LimeGreen"))
                        .onChange(of: themeManager.isDarkMode) { _, isOn in
                            UserDefaults.standard.set(isOn, forKey: "isDarkMode")
                        }
                })
                
                settingRow(icon: "questionmark.circle", text: "CustomerSupport".localized(using: currentLanguage), function: {
                    // go to customer suport website
                    print("Customer Support")
                    openURL(URL(string: "https://zp1v56uxy8rdx5ypatb0ockcb9tr6a-oci3--5173--fb0c4daf.local-credentialless.webcontainer-api.io/")!)
                })
                
                settingRow(icon: "trash", text: "DeleteAccount".localized(using: currentLanguage), function: {
                    // show alert and delete account
                    print("delete account")
                })
                
                settingRow(icon: "rectangle.portrait.and.arrow.right", text: "LogOut".localized(using: currentLanguage), function: {
                    // log out
                    print("logout")
                })
   
                Spacer()

            }
            .onChange(of: isArabic) { _ , value in
                let languageCode = value ? "ar" : "en"
                languageManager.setLanguage(languageCode)
                currentLanguage = languageCode
                if let index = languageManager.supportedLanguages.firstIndex(of: languageCode) {
                    selectedLanguageIndex = index
                }
            }
            .onAppear{
                if let index = languageManager.supportedLanguages.firstIndex(of: currentLanguage) {
                    selectedLanguageIndex = index
                    isArabic = currentLanguage == "ar"
                } else {
                    let defaultLanguage = "en"
                    if let defaultIndex = languageManager.supportedLanguages.firstIndex(of: defaultLanguage) {
                        selectedLanguageIndex = defaultIndex
                        currentLanguage = defaultLanguage
                        isArabic = false
                        languageManager.setLanguage(defaultLanguage)
                    }
                }
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        }
    }
        
}

@ViewBuilder
func settingRow(icon: String, text: String, function: (() -> Void)? = nil, trailingView: () -> some View = { EmptyView() }) -> some View {
    @EnvironmentObject var themeManager: ThemeManager
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
            .foregroundColor(.black)
        
        Spacer()
    
        trailingView()
        
    }
    .padding(.horizontal)
    .frame(width: 350, height: 60)
    .background{
        RoundedRectangle(cornerRadius: 10)
            .stroke(.gray.opacity(0.3), lineWidth: 2)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 3)
    }
    .onTapGesture {
        if let function = function {
            function()
        }
    }
}
