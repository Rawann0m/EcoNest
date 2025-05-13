//
//  Map.swift
//  EcoNest
//
//  Created by Tahani Ayman on 13/11/1446 AH.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject private var viewModel: LocationViewModel
    @Environment(\.dismiss) var dismiss

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
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .padding(10)
                            .background(.thickMaterial)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                    }
                }
            }
        }
    }
}


#Preview {
    MapView()
        .environmentObject(LocationViewModel())
   // LocationMapAnnotationView()
}

// Model
struct Location: Identifiable, Equatable {
    var id = UUID().uuidString
    var name: String
    var description: String
    var coordinates: CLLocationCoordinate2D
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

class LocationDataService {

    static let locations: [Location] = [
        Location(
                name: "Al-Masjid an-Nabawi",
                description: "Al Haram, Central Area, Medina",
                coordinates: CLLocationCoordinate2D(latitude: 24.46833, longitude: 39.61083)
            ),
            Location(
                name: "Quba Mosque",
                description: "Quba Road, Quba, Medina",
                coordinates: CLLocationCoordinate2D(latitude: 24.43917, longitude: 39.61722)
            ),
            Location(
                name: "Mount Uhud",
                description: "As Sayyid Ash Shuhada Street, Medina",
                coordinates: CLLocationCoordinate2D(latitude: 24.51028, longitude: 39.61389)
            ),
            Location(
                name: "Masjid al-Qiblatain",
                description: "Khalid Bin Al-Waleed Rd, Al Khalidiyyah, Medina",
                coordinates: CLLocationCoordinate2D(latitude: 24.48409, longitude: 39.57891)
            ),
            Location(
                name: "Dar Al Madinah Museum",
                description: "King Abdul Aziz Road, Al Madinah Al Munawwarah",
                coordinates: CLLocationCoordinate2D(latitude: 24.46198, longitude: 39.60097)
            )
    ]
    
}

class LocationViewModel: ObservableObject {
    @Published var locations: [Location]
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    @Published var showLocationList: Bool = false
    @Published var showMap: Bool = false
    
    init() {
        let locations = LocationDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        self.updateMapRegion(location: locations.first!)
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation {
            mapRegion = MKCoordinateRegion(center: location.coordinates, span: mapSpan)
        }
    }
    
    func toggleLocationList() {
        withAnimation(.easeInOut) {
            showLocationList.toggle()
        }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationList = false
        }
    }
}


struct LocationMapAnnotationView: View {
    var isSelected: Bool

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isSelected ? Color("LimeGreen").opacity(0.5) : Color.clear)
                    .frame(width: 45, height: 45)

                Image("MapMarker")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            }
            .shadow(radius: 10)
            .padding(.bottom, 40)
        }
    }
}

