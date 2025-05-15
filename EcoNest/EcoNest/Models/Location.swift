//
//  Location.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import Foundation
import MapKit
import FirebaseFirestore

struct Location: Identifiable, Equatable {
    var id: String
    var name: String
    var description: String
    var coordinates: CLLocationCoordinate2D
    var image: String
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

