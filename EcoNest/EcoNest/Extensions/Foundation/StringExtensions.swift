//
//  StringExtensions.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//


import Foundation

extension String {
    
    /// Returns a localized version of the string using the specified language code.
    /// - Parameter languageCode: The ISO language code (e.g., "en", "ar").
    /// - Returns: The localized string from the corresponding .lproj localization file, or the default system-localized string if the language code is invalid or missing.
    func localized(using languageCode: String) -> String {
        
        // Attempt to locate the language bundle
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback: return default localized string (based on system language)
            return NSLocalizedString(self, comment: "")
        }
        
        // Return localized string using the found bundle
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
