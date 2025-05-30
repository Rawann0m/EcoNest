//
//  SearchView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//


import SwiftUI

/// A reusable search bar component used to filter products in the home screen
struct SearchView: View {
    
    /// The view model responsible for handling the search input and filtered product list
    @ObservedObject var viewModel: HomeViewModel
    
    /// Stores the current language setting for localization
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        HStack {
            // Magnifying glass icon on the left side of the search bar
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading)
            
            // Text field for user input
            TextField("Search".localized(using: currentLanguage), text: $viewModel.search)
                .padding()
                .foregroundColor(.primary)
                .disableAutocorrection(true) // Prevent autocorrect suggestions
                .textInputAutocapitalization(.none) // Disable auto-capitalization for accurate search matching
        }
        .background(.gray.opacity(0.15))
        .frame(height: 50)
        .cornerRadius(12)
        .padding(.horizontal, 16) 
    }
}


