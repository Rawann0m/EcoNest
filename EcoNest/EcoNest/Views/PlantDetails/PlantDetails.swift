//
//  PlantDetails.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct PlantDetails: View {
    var plantName: String
    
    @StateObject var plantDetailsVM : PlantDetailsViewModel
    
    init(plantName: String) {
        self.plantName = plantName
        _plantDetailsVM = StateObject(wrappedValue: PlantDetailsViewModel(PlantName: plantName))
    }
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16){
                ZStack(alignment: .top) {
                    CustomRoundedRectangle(topLeft: 0, topRight: 0, bottomLeft: 45, bottomRight: 45)
                        .fill(Color("DarkGreen"))
                        .frame(width: UIScreen.main.bounds.width, height: 350)
                        .ignoresSafeArea(edges: .top)
                    
                    PlantDetailBar(plantName: plantName)
                        .padding(.top, 42)
                    
                    if let imageUrl = plantDetailsVM.plant?.image,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .padding(.top, 100)
                            case .failure:
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let plant = plantDetailsVM.plant {
                        Text("\(plant.name):")
                            .font(.title)
                    }
                    
                    if let desc = plantDetailsVM.plant?.description {
                        Text(desc)
                            .font(.title3)
                        
                    }
                }
                .padding(8)
                .background(Color("LimeGreen"))
                .cornerRadius(10)
                .padding()
                
                
                if !plantDetailsVM.products.isEmpty {
                    Text("Recommended Products")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(plantDetailsVM.products) { product in
                                ProductCard(product: product)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                
            }
            
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
    
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let url = URL(string: product.image ?? "") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 120)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Text(product.name ?? "").font(.subheadline).bold()
            Text("SAR \(product.price ?? 0.0, specifier: "%.2f")")
                .font(.caption)
        }
        .frame(width: 140)
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
