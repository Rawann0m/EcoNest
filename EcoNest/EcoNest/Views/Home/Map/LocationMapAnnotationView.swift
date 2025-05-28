//
//  LocationMapAnnotationView.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//

import SwiftUI


/// A custom SwiftUI view used to display a map annotation with a selectable state.
struct LocationMapAnnotationView: View {
    
    /// Indicates whether the annotation is currently selected.
    var isSelected: Bool

    var body: some View {
        VStack {
            ZStack {
                // Background circle appears only when the annotation is selected
                Circle()
                    .fill(
                        isSelected
                            ? (ThemeManager().isDarkMode
                                ? Color("LightGreen").opacity(0.5)
                                : Color("LimeGreen").opacity(0.5))
                            : Color.clear
                    )
                    .frame(width: 45, height: 45)

                // Central marker image
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
