//
//  EcoNestApp.swift
//  EcoNest
//
//  Created by Rawan on 04/05/2025.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct YourApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject var localizableManager = LanguageManager()
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {

//          WelcomePage()
//              .environmentObject(localizableManager)
//              .environmentObject(themeManager)
//              .environmentObject(AlertManager.shared)
//              .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)

          SettingsView()
                        .environmentObject(localizableManager)
                        .environmentObject(themeManager)
                        .environmentObject(AlertManager.shared)
                        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)

      }
    }
  }
}
