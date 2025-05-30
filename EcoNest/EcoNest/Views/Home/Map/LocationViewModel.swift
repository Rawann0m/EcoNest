//
//  LocationViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI
import MapKit
import FirebaseFirestore

/// ViewModel that manages the state and behavior for map-based location selection and navigation.
class LocationViewModel: ObservableObject {
    
    /// List of all pickup locations loaded from Firestore.
    @Published var locations: [Location] = []
    
    /// Controls visibility of the location list dropdown.
    @Published var showLocationList: Bool = false
    
    /// Controls whether the map view is currently being shown.
    @Published var showMap: Bool = false
    
    /// The current region displayed on the map.
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    /// The currently selected location.
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    /// Fixed zoom level (span) used for all map regions.
    let mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
    
    /// Initializer sets default values and triggers loading of locations.
    init() {
        self.locations = []
        self.mapLocation = Location(
            id: "",
            name: "",
            description: "",
            coordinates: CLLocationCoordinate2D(latitude: 24.46833, longitude: 39.61083),
            image: ""
        )
        self.mapRegion = MKCoordinateRegion()
        self.showLocationList = false
        self.showMap = false
        self.fetchLocations()
    }
    
    /// Loads pickup locations from Firestore and updates the locations array.
    /// Also sets the first location as the default selected location and map center.
    func fetchLocations() {
        
        let db = FirebaseManager.shared.firestore
        
        db.collection("pickupLocations").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error loading locations")
                return
            }
            
            // Map Firestore documents to Location model instances.
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
            
            // Update UI state on the main thread.
            DispatchQueue.main.async {
                self.locations = loadedLocations
                if let first = loadedLocations.first {
                    self.mapLocation = first
                    self.updateMapRegion(location: first)
                }
            }
        }
    }
    
    /// Updates the visible map region based on the selected location.
    private func updateMapRegion(location: Location) {
        withAnimation {
            mapRegion = MKCoordinateRegion(center: location.coordinates, span: mapSpan)
        }
    }
    
    /// Toggles the visibility of the location list dropdown with animation.
    func toggleLocationList() {
        withAnimation(.easeInOut) {
            showLocationList.toggle()
        }
    }
    
    /// Selects a given location and updates the map, hiding the location list.
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationList = false
        }
    }
    
    /// Advances to the next location in the list. Wraps to the first if at the end.
    func nextButtonPressed() {
        guard let currentIndex = locations.firstIndex(where: { $0 == mapLocation }) else {
            print("No current index")
            return
        }
        
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else {
            // Loop back to the first location if the next index is out of bounds.
            if let firstLocation = locations.first {
                showNextLocation(location: firstLocation)
            }
            return
        }
        
        let nextLocation = locations[nextIndex]
        showNextLocation(location: nextLocation)
    }
}
