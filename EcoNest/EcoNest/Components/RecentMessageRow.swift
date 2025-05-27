//
//  RecentMessageRow.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 21/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A view that displays a recent message row in the chat list, including profile image, username, message preview, timestamp, and unread count.
///
/// - Parameters:
///   - username: The name of the user sending or receiving the message.
///   - email: The user's email (currently unused in the view, but can be used for navigation or future needs).
///   - image: URL string of the user's profile image. Defaults to a placeholder image if empty.
///   - time: The time when the message was sent, shown in a compact format (e.g., "2h").
///   - message: The latest message content, or "Picture" if it's a Firebase image URL.
///   - count: Number of unread messages (shown in a circle badge if > 0).
@ViewBuilder
func RecentMessageRow(username: String, email: String, image: String, time: String, message: String, count: Int) -> some View {
    
    @EnvironmentObject var themeManager: ThemeManager

    HStack {
        // Profile image section
        Group {
            if image.isEmpty {
                // profile image if none is provided
                Image("profile")
                    .resizable()
            } else if let imageURL = URL(string: image) {
                // Display remote profile image using WebImage
                WebImage(url: imageURL)
                    .resizable()
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(50)
        .background {
            // Adds a circular border to the image
            Circle()
                .stroke(Color("DarkColor"), lineWidth: 3)
        }

        // Username and message preview section
        VStack(alignment: .leading) {
            Text(username)
                .font(.headline)
                .padding(.bottom, 5)

            Group {
                // If message is an image URL from Firebase, display "Picture"
                if message.lowercased().hasPrefix("https://firebasestorage") {
                    Text("Picture")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    // Show the actual message preview
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }

        Spacer()

        // Time and unread count section
        VStack {
            Text(time)
                .font(.caption)

            if count > 0 {
                // Display unread message count in green circular badge
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color("LimeGreen"), in: .circle)
            } else {
                // Maintain layout when no unread messages
                Text("")
                    .padding(5)
            }
        }
    }
}
