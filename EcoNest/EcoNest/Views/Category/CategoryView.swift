//
//  CategoryView.swift
//  EcoNest
//
//  Created by Mac on 08/11/1446 AH.
//
import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var isFilterPresented = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
               // categoryList
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    // MARK: -  Header (Title + Search + Filter)
    private var headerSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Categories")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    isFilterPresented.toggle()
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .imageScale(.large)
                        .foregroundColor(.black)
                }
                .sheet(isPresented: $isFilterPresented) {
                    Text("Filter Options Placeholder")
                        .font(.title)
                }
            }
            .padding(.horizontal, 20)
            
            // Search Bar
            HStack {
                TextField("Search", text: $viewModel.searchText)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    )
                    .padding(.horizontal, 8)
            }
            .padding(.bottom, 10)
        }
        .padding(.top, 50)
        .padding(.bottom, 20)
        .background(Color("LimeGreen"))
        .cornerRadius(25)
    }
    
    // MARK: - Category List
    //    private var categoryList: some View {
    //        ScrollView {
    //            LazyVStack(spacing: 12) {
    //                ForEach(viewModel.filteredCategories) { category in
    //                    CategoryRowView(category: category)
    //                }
    //            }
    //            .padding(.top, 10)
    //        }
    //    }
    //}
}
