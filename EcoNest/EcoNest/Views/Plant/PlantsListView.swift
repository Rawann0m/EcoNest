//
//  PlantsListView.swift
//  EcoNest
//
//  Created by Mac on 20/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// View displaying a list of plants with search and filter functionalities
struct PlantsListView: View {
    @StateObject private var viewModel = PlantViewModel()  // ViewModel to manage plants and filters
    @State private var showFilterSheet = false             // Controls display of filter sheet
    @EnvironmentObject var themeManager: ThemeManager      // Manages light/dark mode theme
    
    // Observes the current language preference for localization
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // MARK: - Header (Title + Filter Button + Search Bar)
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Title and Filter Button
                    HStack {
                        Text("AllPlants".localized(using: currentLanguage))  // Localized title
                            .font(.title)
                            .foregroundColor(themeManager.isDarkMode ? .black : .white)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Filter button
                        Button {
                            showFilterSheet.toggle()
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.title2)
                                .foregroundColor(themeManager.isDarkMode ? .black : .white)
                        }
                    }
                    
                    // Search Bar
                    TextField("🔍 Search plants...", text: $viewModel.searchText)
                        .padding(10)
                        .background(themeManager.isDarkMode ? .black : .white)
                        .cornerRadius(10)
                        .onChange(of: viewModel.searchText) { _ in
                            viewModel.applyFilters()  // Apply filter when text changes
                        }
                }
                .padding(.horizontal)
                .padding(.top, 60)
                .padding(.bottom)
                .background(
                    Color("LimeGreen") // Custom header background
                        .mask(
                            RoundedRectangle(cornerRadius: 30)
                                .padding(.top, -30) // Makes top corners flat and bottom rounded
                        )
                )
                .foregroundColor(themeManager.isDarkMode ? .white : .black)

                // MARK: - Plant List
                List(viewModel.filteredPlants) { plant in
                    NavigationLink {
                        PlantDetails(plantName: plant.name) // Navigate to detail view
                    } label: {
                        HStack {
                            // Plant image using SDWebImage
                            WebImage(url: URL(string: plant.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            // Plant details (name and categories)
                            VStack(alignment: .leading) {
                                Text(plant.name)
                                    .fontWeight(.semibold)
                                Text(plant.category.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .id(currentLanguage)  // Reloads the list when language changes
                .listStyle(.plain)
                .padding(.bottom, 30)  // Space at bottom for better layout
            }
            .edgesIgnoringSafeArea(.top)  // Allows header to extend to the top edge
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(viewModel: viewModel, isPresented: $showFilterSheet)  // Filter sheet modal
            }
        }
    }
}
