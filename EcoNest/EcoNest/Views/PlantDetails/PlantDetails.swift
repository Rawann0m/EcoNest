//
//  PlantDetails.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

struct PlantDetails: View {
    @State var plantName: String
    
    @StateObject var plantDetailsVM : PlantDetailsViewModel
    
    @State var outOf: Double = 100
    
    init(plantName: String) {
        self.plantName = plantName
        _plantDetailsVM = StateObject(wrappedValue: PlantDetailsViewModel(PlantName: plantName))
        
    }
    let userId = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16){
                ZStack(alignment: .top) {
                    CustomRoundedRectangle(topLeft: 0, topRight: 0, bottomLeft: 45, bottomRight: 45)
                        .fill(Color("DarkGreen"))
                        .frame(width: UIScreen.main.bounds.width, height: 350)
                        .ignoresSafeArea(edges: .top)
                    
                    PlantDetailBar(
                        plantName: plantName,
                        viewModel: plantDetailsVM,
                        userId: userId,
                        plantId: plantDetailsVM.plant?.id ?? ""
                    )
                    
                    
                    
                    if let imageUrl = plantDetailsVM.plant?.image,
                       let url = URL(string: imageUrl) {
                        WebImage(url: url) { phase in
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
                        Text("\(String(describing: plant.name)):")
                            .font(.title)
                            .bold()
                    }
                    
                    if let desc = plantDetailsVM.plant?.description {
                        Text(desc)
                            .font(.title3)
                        
                    }
                }.padding(.horizontal)
                
                HStack {
                    ShapeView(usedWaterAmount: CGFloat(plantDetailsVM.waterLevel ?? 0.0), maxWaterAmount: CGFloat(outOf), color: Color("LimeGreen").opacity(0.4), icon: "drop.fill")
                    
                    ShapeView(usedWaterAmount: CGFloat(plantDetailsVM.lightLevel ?? 0.0), maxWaterAmount: CGFloat(outOf), color: Color("LimeGreen").opacity(0.4), icon: "sun.max.fill")
                }
                
                
                
                if !plantDetailsVM.products.isEmpty {
                    HStack {
                        Text("Recommended Products:")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)   // ← pins to left
                            .padding(.horizontal)
                        Spacer()
                        Button {
                            // TODO: present full-list view or sheet
                            print("See All tapped")
                        } label: {
                            Text("See All")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                    
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
        .onChange(of: plantDetailsVM.plant?.id) { newPlantId in
            if let id = newPlantId {
                plantDetailsVM.checkFavoriteStatus(userId: userId, plantId: id)
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
                WebImage(url: url) { phase in
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
                .frame(maxWidth: .infinity, alignment: .center)
            Text("SAR \(product.price ?? 0.0, specifier: "%.2f")")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 140)
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
