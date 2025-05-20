//
//  PlantDetails.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct PlantDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var plantName: String
    
    @StateObject var plantDetailsVM : PlantDetailsViewModel
    
    init(plantName: String) {
        self.plantName = plantName
        _plantDetailsVM = StateObject(wrappedValue: PlantDetailsViewModel(PlantName: plantName))
    }
    
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        
        
        
        ScrollView {
            
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)
            
            
            VStack(spacing: 16){
                
                CustomRoundedRectangle(topLeft: 0, topRight: 0, bottomLeft: 45, bottomRight: 45)
                    .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
                    .fill(Color("DarkGreen"))
                    .ignoresSafeArea(edges: .top)
                    .overlay(
                        VStack {
                            Spacer().frame(height: 400)
                            
                            if let imageUrl = plantDetailsVM.plant?.image,
                               let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(height: 300)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundColor(.white)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    )
                
                
                Spacer().frame(height: 1500)
                
                if let plant = plantDetailsVM.plant {
                    Text("Details for \(plant.name)")
                        .font(.title)
                }
                
                
                
            }
            
        }
        .ignoresSafeArea(.all)
        .overlay(
            Color.white
                .opacity(scrollOffset < -50 ? 1 : 0)
                .ignoresSafeArea(edges: .top)
                .animation(.easeInOut(duration: 0.2), value: scrollOffset)
        , alignment: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            withAnimation(.easeInOut(duration: 0.2)) {
                scrollOffset = value
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(plantName)
                    }
                    .foregroundColor(scrollOffset < -30 ? .black : .white)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Button Action
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(scrollOffset < -5 ? .black : .white)
                }
            }
        }
        
        
    }
}
