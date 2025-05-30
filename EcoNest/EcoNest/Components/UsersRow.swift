//
//  UsersRow.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI
import SDWebImageSwiftUI

/// A view that displays a user's row with profile image, username,
/// and a "chat" indicator if the current user is different from the displayed user and messaging is enabled.
///
/// - Parameters:
///   - user: The User model containing user information.
///   - image: The URL string for the user's profile image.
///   - receiveMessages: A Boolean indicating whether to show the chat option.
@ViewBuilder
func UsersRow(user: User, image: String, receiveMessages: Bool) -> some View {
    HStack(alignment: .center) {
        @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
        VStack {
            // Show default profile image if no URL is provided
            if image.isEmpty {
                Image("profile")
                    .resizable()
            }
            // Otherwise, load profile image from URL using WebImage
            else if let imageURL = URL(string: image) {
                WebImage(url: imageURL)
                    .resizable()
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(50)
        // Circular border around the profile image
        .background {
            Circle()
                .stroke(Color(red: 7/255, green: 39/255, blue: 29/255), lineWidth: 3)
        }
        
        // Display the username next to the profile image
        Text(user.username)
            .font(.headline)
        
        Spacer()
        
        // Show "chat" text if the current user is not the same as this user AND receiveMessages is true
        if FirebaseManager.shared.auth.currentUser?.uid != user.id && receiveMessages {
            Text("chat".localized(using: currentLanguage))
                .bold()
                .foregroundColor(Color("LimeGreen"))
                .padding(.horizontal)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
}
