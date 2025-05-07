//
//  SearchView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//


import SwiftUI

// MARK: - SearchView (Custom Search Bar)
struct SearchView: View {
    
    // State variable to hold the user’s search input
    @State private var search: String = ""
    
    var body: some View {
        
        HStack {
            // Search icon on the left
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading)
            
            // Text field for entering search text
            TextField("Search for plants ...", text: $search)
                .padding()
                .foregroundColor(.primary)
                .disableAutocorrection(true) // Prevents autocorrect
                .textInputAutocapitalization(.none) // Disables auto-capitalization for better search accuracy
        }
        .background(.gray.opacity(0.15))
        .frame(height: 50)
        .cornerRadius(12)
        .padding(.horizontal, 16) 
    }
}

