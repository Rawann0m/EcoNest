//
//  LocationViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI
import MapKit
import FirebaseFirestore

class LocationViewModel: ObservableObject {
    
    @Published var locations: [Location] = []
    @Published var showLocationList: Bool = false
    @Published var showMap: Bool = false
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    let mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
    
    init() {
        self.locations = []
        self.mapLocation = Location.init(id: "", name: "", description: "", coordinates: CLLocationCoordinate2D(latitude: 24.46833, longitude: 39.61083), image: "")
            self.mapRegion = MKCoordinateRegion()
            self.showLocationList = false
            self.showMap = false
            self.loadLocations()
    }
    
    func loadLocations() {
        let db = FirebaseManager.shared.firestore
        db.collection("pickupLocations").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error loading locations")
                return
            }
            
            let loadedLocations = documents.compactMap { doc -> Location? in
                let id = doc.documentID
                guard
                    let name = doc["name"] as? String,
                    let description = doc["description"] as? String,
                    let geoPoint = doc["coordinates"] as? GeoPoint,
                    let image = doc["image"] as? String
                else {
                    return nil
                }
                
                let coordinates = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                return Location(id: id, name: name, description: description, coordinates: coordinates, image: image)
            }
            
            DispatchQueue.main.async {
                self.locations = loadedLocations
                if let first = loadedLocations.first {
                    self.mapLocation = first
                    self.updateMapRegion(location: first)
                }
            }
        }
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
    
    func nextButtonPressed() {
        guard let currentIndex = locations.firstIndex(where: {$0 == mapLocation}) else {
            print("No current index")
            return
        }
        
        let nextIndex = (currentIndex + 1)
        guard locations.indices.contains(nextIndex) else {
            guard let firstLocation = locations.first else {
                return
            }
            showNextLocation(location: firstLocation)
            return
        }
        
        let nextLocation = locations[nextIndex]
        showNextLocation(location: nextLocation)
    }
}
