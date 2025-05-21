//
//  EcoNestApp.swift
//  EcoNest
//
//  Created by Rawan on 04/05/2025.
//

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct YourApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject var localizableManager = LanguageManager()
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var locationviewModel = LocationViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(localizableManager)
                .environmentObject(themeManager)
                .environmentObject(AlertManager.shared)
                .environmentObject(locationviewModel)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            
        }
    }
}
