//
//  Settings.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 07/11/1446 AH.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct SettingsView: View {
    @State var isEdit: Bool = false
    @State private var isArabic: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @State private var selectedLanguageIndex: Int = 0
    @Environment(\.openURL) var openURL
    @State var name: String = ""
    @State var oldName = ""
    @State var email: String = ""
    @State var profileImage: String = ""
    @State var login: Bool = false
    @StateObject var viewModel = SettingsViewModel()
    @State var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State var showImagePicker: Bool = false
    var body: some View {
        NavigationStack{
            GeometryReader { _ in
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
                        
                        
                        VStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                            } else if let imageURL = URL(string: profileImage) {
                                WebImage(url: imageURL)
                                    .resizable()
                            } else {
                                Image("profile")
                                    .resizable()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(50)
                        .background {
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
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
                        }
                        
                        if FirebaseManager.shared.isLoggedIn {
                            Image(systemName: isEdit ? "checkmark" : "pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("DarkGreen"))
                                .offset(x: 150, y: 50)
                                .onTapGesture {
                                    if oldName != name || selectedImage != nil {
                                        if isEdit {
                                            viewModel.updateUserInformation(user: User(username: name, email: email, profileImage: profileImage), newImage: selectedImage)
                                            print("edit")
                                        }
                                    }
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
                            
                            if FirebaseManager.shared.isLoggedIn {
                                Text(email)
                                    .frame(width: 200)
                            } else {
                                Text("Login/Create Account")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background{
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("LimeGreen"))
                                    }
                                    .onTapGesture {
                                        login.toggle()
                                    }
                            }
                        }
                        .offset(y: 110)
                        .ignoresSafeArea(.keyboard, edges: .all)
                        //                        .scrollDismissesKeyboard(.interactively)
                        
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
                    
                    
                    if FirebaseManager.shared.isLoggedIn {
                        settingRow(icon: "trash", text: "DeleteAccount".localized(using: currentLanguage), function: {
                            // show alert and delete account
                            print("delete account")
                        })
                        
                        settingRow(icon: "rectangle.portrait.and.arrow.right", text: "LogOut".localized(using: currentLanguage), function: {
                            // log out
                            if FirebaseManager.shared.isLoggedIn{
                                print("logout")
                            } else {
                                
                            }
                        })
                    }
                    
                    Spacer()
                    
                }
                .photosPicker(
                    isPresented: $showImagePicker,
                    selection: $selectedItem,
                    matching: .images
                )
                .onChange(of: selectedItem) { _ , newItem in
                    Task { @MainActor in
                        if let newItem,
                           let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            self.selectedImage = uiImage
                            print("Updated selectedImage: \(uiImage)")
                        }
                    }
                }
                .fullScreenCover(isPresented: $login, content: {
                    LogInPage()
                })
                .onChange(of: isArabic) { _ , value in
                    let languageCode = value ? "ar" : "en"
                    languageManager.setLanguage(languageCode)
                    currentLanguage = languageCode
                    if let index = languageManager.supportedLanguages.firstIndex(of: languageCode) {
                        selectedLanguageIndex = index
                    }
                }
                .onChange(of: viewModel.user) { newUser, _ in
                    if let user = newUser {
                        name = user.username
                        email = user.email
                        profileImage = user.profileImage
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
                    
                    let currentUser = viewModel.user
                    if let user = currentUser {
                        name = user.username
                        oldName = user.username
                        email = user.email
                        profileImage = user.profileImage
                    }
                    print(FirebaseManager.shared.auth.currentUser?.uid ?? "no user")
                }
                .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

