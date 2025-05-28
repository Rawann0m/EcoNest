//
//  AuthButton.swift
//  ExpanseTracker
//
//  Created by Rawan on 12/10/1446 AH.
//


import SwiftUI

/// A custom authentication button used for log in and sign up screens.
/// The button supports both filled and outlined styles based on the `isFilled` flag.
struct AuthButton: View {
    //MARK: - Variables
    let label: String
    @EnvironmentObject var themeManager: ThemeManager
    
    //MARK: - View
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill( Color.white.opacity(0.7))
                .frame(width: 350, height: 50)
        }
    }
}
