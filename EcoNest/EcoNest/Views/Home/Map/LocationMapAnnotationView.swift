//
//  LocationMapAnnotationView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI


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

