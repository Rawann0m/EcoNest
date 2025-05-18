//
//  FilterSheet.swift
//  EcoNest
//
//  Created by Mac on 20/11/1446 AH.
//

import SwiftUI

struct FilterSheet: View {
    @ObservedObject var viewModel: PlantViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                // Category checkbox list
                ForEach(viewModel.allCategories, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        if viewModel.selectedCategories.contains(category) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if viewModel.selectedCategories.contains(category) {
                            viewModel.selectedCategories.removeAll { $0 == category }
                        } else {
                            viewModel.selectedCategories.append(category)
                        }
                    }
                }
            }
            .navigationTitle("Filter Categories")
            .toolbar {
                // Apply button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        isPresented = false
                    }
                }
            
            }
        }
    }
}
