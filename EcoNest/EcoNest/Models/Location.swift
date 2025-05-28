//
//  Location.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import Foundation
import MapKit
import FirebaseFirestore

/// A model representing a geographic location.
struct Location: Identifiable, Equatable {
    
    var id: String
    var name: String
    var description: String
    /// Geographic coordinates of the location (latitude and longitude)
    var coordinates: CLLocationCoordinate2D
    var image: String

    /// Equality check based on the `id` property to determine if two locations are the same
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}


