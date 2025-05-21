//
//  MapView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 13/11/1446 AH.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject private var viewModel: LocationViewModel
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: location.coordinates) {
                        LocationMapAnnotationView(isSelected: viewModel.mapLocation == location)
                            .onTapGesture {
                                viewModel.showNextLocation(location: location)
                            }
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack {
                        Button(action: viewModel.toggleLocationList) {
                            Text(viewModel.mapLocation.name)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .animation(.none, value: viewModel.mapLocation)
                                .overlay(alignment: .leading) {
                                    Image(systemName: "arrow.down")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding()
                                        .rotationEffect(Angle(degrees: viewModel.showLocationList ? 180 : 0))
                                }
                        }
                        
                        if viewModel.showLocationList {
                            List {
                                ForEach(viewModel.locations) { location in
                                    Button {
                                        viewModel.showNextLocation(location: location)
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(location.name)
                                                .font(.headline)
                                                .padding(.vertical, 10)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .listRowBackground(Color.clear)
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .background(.thickMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        ForEach(viewModel.locations) { location in
                            if viewModel.mapLocation == location {
                                LocationPreviewView(location: location, currentLanguage: currentLanguage)
                                    .shadow(color: .black.opacity(0.3), radius: 20)
                                    .padding()
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: currentLanguage == "ar" ? .navigationBarTrailing : .navigationBarLeading) {
                    Button {
                        viewModel.showMap = false
                    } label: {
                        Image(systemName: "xmark")
                            .padding(10)
                            .background(.thickMaterial)
                            .cornerRadius(10)
                            .foregroundStyle(ThemeManager().isDarkMode ? .white: .black)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                    }
                }
            }
            .environment(\.layoutDirection, currentLanguage == "ar" ? .rightToLeft : .leftToRight)
        }
    }
}
