//
//  ThemeManager.swift
//  ExpanseTracker
//
//  Created by Rawan on 12/10/1446 AH.
//


import SwiftUI

/// Manages the app's theme appearance (Dark/Light mode) and provides adaptive colors
class ThemeManager: ObservableObject {
    
    // MARK: - Variables
        @Published var isDarkMode: Bool {
            didSet {
                UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            }
        }
        
        // MARK: - Init
        init() {
            // Load the saved mode or fallback to false
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    
    // Colors that adapt to dark/light mode
    var backgroundColor: Color {
        isDarkMode ? Color("DarkGreen") : Color("DarkGreenLight")
    }
    
    var textColor: Color {
        isDarkMode ?  Color("LightGreen") : Color("DarkGreen")
    }
    
    var secondaryColor: Color {
        isDarkMode ? Color.gray.opacity(0.4) : Color.gray.opacity(0.15)
    }

    
    var gradient: LinearGradient {
        isDarkMode ? 
        LinearGradient(colors: [Color.white, Color.gray.opacity(0.7)], startPoint: .top, endPoint: .bottom) :
            LinearGradient(colors: [Color.gray.opacity(0.7), Color.white], startPoint: .top, endPoint: .bottom)
    }
}
