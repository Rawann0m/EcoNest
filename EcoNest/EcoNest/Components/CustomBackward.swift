//
//  CustomBackward.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//

import SwiftUI
/// A reusable custom back-navigation view component.
/// `CustomBackward` displays a back arrow icon (`arrow.left`) and a title label.
/// Tapping on the arrow icon triggers a custom event closure, making it useful for navigation bars or custom headers.
///
/// - Parameters:
///   - title: The title text displayed next to the arrow.
///   - tapEvent: A closure executed when the arrow icon is tapped.
@ViewBuilder
func CustomBackward(title: String, tapEvent: @escaping () -> Void) -> some View {
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    HStack{
        // Back icon with tap event to dimiss the view
        Image(systemName: currentLanguage == "ar" ? "chevron.right" : "chevron.left")
            .font(.system(size: 18))
            .contentShape(Rectangle())
            
        // Page title
        Text(title)
            .font(.system(size: 22))
            .bold()
    }.onTapGesture {
        tapEvent()
    }
}
