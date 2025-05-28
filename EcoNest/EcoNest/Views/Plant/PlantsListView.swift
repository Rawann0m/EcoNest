//
//  PlantsListView.swift
//  EcoNest
//
//  Created by Mac on 20/11/1446 AH.
//
import SwiftUI
import SDWebImageSwiftUI

struct PlantsListView: View {
    @StateObject private var viewModel = PlantViewModel()
    @State private var showFilterSheet = false
    @EnvironmentObject var themeManager: ThemeManager
    // Stores and observes the current language preference
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Green header with title, filter button, and search bar
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("AllPlants".localized(using: currentLanguage))
                            .font(.title)
                            .foregroundColor(themeManager.isDarkMode ? Color.black : Color.white)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            showFilterSheet.toggle()
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.title2)
                                .foregroundColor(themeManager.isDarkMode ? Color.black : Color.white)

                        }
                    }
                    
                    // Search bar
                    TextField("🔍 Search plants...", text: $viewModel.searchText)
                        .padding(10)
                        .background(themeManager.isDarkMode ? Color.black : Color.white)
                        .cornerRadius(10)
                        .onChange(of: viewModel.searchText) { _ in
                            viewModel.applyFilters()
                        }
                }
                .padding(.horizontal)
                .padding(.top, 60)
                .padding(.bottom)
                .background(
                    Color("LimeGreen")
                        .mask(
                            RoundedRectangle(cornerRadius: 30)
                                .padding(.top, -30) // Top corners = 0, Bottom corners = 30
                        )
                )
                .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)

                // Plant list
                List(viewModel.filteredPlants) { plant in
                    NavigationLink {
                        PlantDetails(plantName: plant.name)
                    } label: {
                        HStack {
                            // Plant image
                            WebImage(url: URL(string: plant.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            // Plant info
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
                .id(currentLanguage)
                .listStyle(.plain)
                .padding(.bottom , 30)
            }
            .edgesIgnoringSafeArea(.top)
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(viewModel: viewModel, isPresented: $showFilterSheet)
            }
        }
    }
}

