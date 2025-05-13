//
//  ReviewView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 13/11/1446 AH.
//

import SwiftUI
import MapKit

struct ReviewView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CartViewModel
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    @State private var selectedDate = Date()
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.46833, longitude: 39.61083),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State var showMap: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        
                        Map(coordinateRegion: $mapRegion)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("DarkGreen"), lineWidth: 2)
                            )
                            .onTapGesture {
                                withAnimation {
                                    showMap.toggle()
                                }
                            }

                        HStack {
                            Text("Pickup Date:")
                            Spacer()
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        }
                        .padding(.vertical)
                        
                        VStack {
                            ForEach(viewModel.cartProducts) { cart in
                                HStack(spacing: 15) {
                                    Text(cart.product.name)
                                        .frame(width: 180, alignment: .leading)
                                        
                                    Text("qty: \(cart.quantity)")
                                        .frame(width: 70, alignment: .leading)
                                        
                                    HStack {
                                        Text("\(cart.price, specifier: "%.2f")")
                                        
                                        Image(themeManager.isDarkMode ? "RiyalW" : "RiyalB")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                    }
                                    .frame(width: 90, alignment: .leading)
                                        
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                Divider()
                            }
                            
                            Text("Total: \(viewModel.calculateTotal(), specifier: "%.2f")")
                                .padding()
                        }
                    }
                }
                
                NavigationLink(destination: Text("Confirm")) {
                    Text("Confirm")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("LimeGreen"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .buttonStyle(.plain)
            }
            .padding()
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
            .overlay {
                if showMap {
                    MapView()
                }
            }
        }
    }
}


