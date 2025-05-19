//
//  PlantDetails.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 15/05/2025.
//

import SwiftUI

struct PlantDetails: View {
    let plantName: String

    var body: some View {
        VStack {
            Text("Details for \(plantName)")
                .font(.title)
            // Add more detailed info here
        }
        .navigationTitle(plantName)
    }
}

