//
//  FilterSheet.swift
//  EcoNest
//
//  Created by Mac on 20/11/1446 AH.
//

import SwiftUI

/// A modal sheet that displays a list of plant categories for filtering.
struct FilterSheet: View {
    @ObservedObject var viewModel: PlantViewModel     // ViewModel that manages plants and filter logic
    @Binding var isPresented: Bool                    // Controls the visibility of this sheet

    // Observes the current language for localization
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Category Filter List
                ForEach(viewModel.allCategories, id: \.self) { category in
                    HStack {
                        Text(category)  // Display category name
                        Spacer()
                        
                        // Show checkmark if category is selected
                        if viewModel.selectedCategories.contains(category) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle()) // Makes the whole row tappable
                    .onTapGesture {
                        // Toggle selection state
                        if viewModel.selectedCategories.contains(category) {
                            viewModel.selectedCategories.removeAll { $0 == category }
                        } else {
                            viewModel.selectedCategories.append(category)
                        }
                    }
                }
            }
            .navigationTitle("FilterCategories".localized(using: currentLanguage))  // Localized title
            .toolbar {
                // MARK: - Apply Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply".localized(using: currentLanguage)) {
                        viewModel.applyFilters()  // Apply selected filters
                        isPresented = false       // Dismiss the sheet
                    }
                }
            }
        }
    }
}
