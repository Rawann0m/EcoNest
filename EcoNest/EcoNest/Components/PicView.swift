//
//  PicView.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 17/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A full-screen overlay view to display an image from a URL with a dimmed background.
///
/// `PicView` shows a semi-transparent black background and loads the image from a provided URL using `WebImage`.
/// Tapping anywhere on the view toggles the `showPic` binding, typically used to dismiss the image viewer.
///
/// - Parameters:
///   - pic: A `String` representing the image URL to be displayed.
///   - showPic: A binding `Bool` value used to control the visibility of the image view.
struct PicView: View {
    
    // The URL string of the image to display.
    var pic: String

    // A binding to control the visibility of the image view overlay.
    @Binding var showPic: Bool

    var body: some View {
        ZStack {
            // black background covering the entire screen.
            Color.black.opacity(0.6).ignoresSafeArea(edges: .all)

            // Image container.
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: pic) {
                    // Displays the image using SDWebImageSwiftUI's WebImage.
                    WebImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        // Tapping the overlay toggles visibility (used to dismiss).
        .onTapGesture {
            showPic.toggle()
        }
    }
}
