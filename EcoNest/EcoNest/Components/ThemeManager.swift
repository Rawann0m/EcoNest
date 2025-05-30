//
//  ThemeManager.swift
//  EcoNest
//
//  Created by Rawan on 12/10/1446 AH.
//

import SwiftUI

/// Manages the app's theme appearance (Dark/Light mode) and provides adaptive colors
class ThemeManager: ObservableObject {
    
    // MARK: - Variables
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    // Colors that adapt to dark/light mode
    var backgroundColor: Color {
        isDarkMode ? Color("DarkGreen") : Color("DarkGreenLight")
    }
    
    var textColor: Color {
        isDarkMode ? .white : Color("DarkGreen")
    }
    
    var secondaryColor: Color {
        isDarkMode ? Color.gray.opacity(0.4) : Color.gray.opacity(0.15)
    }
}
