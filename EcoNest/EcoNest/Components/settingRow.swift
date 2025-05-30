//
//  settingRow.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 09/11/1446 AH.
//

import SwiftUI

/// A reusable setting row view component that displays an icon, a text label, and an optional trailing view.
/// It also supports an optional tap action.
///
/// - Parameters:
///   - icon: The name of the system image to display as the icon.
///   - text: The main text label of the row.
///   - function: An optional closure executed when the row is tapped.
///   - trailingView: A trailing view displayed on the right side of the row (defaults to empty).
///   - color: The color applied to the text label.
@ViewBuilder
func settingRow(
    icon: String,
    text: String,
    function: (() -> Void)? = nil,
    trailingView: () -> some View = { EmptyView() },
    color: Color
) -> some View {
    HStack(spacing: 16) {
        
        // Icon background and symbol
        ZStack {
            // Rounded rectangle with light green translucent fill behind the icon
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("LimeGreen").opacity(0.3))
                .frame(width: 50, height: 50)
            
            // Icon image from SF Symbols, sized and colored
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(Color("LimeGreen"))
        }
        
        // Main text label, bold and colored according to passed color
        Text(text)
            .bold()
            .foregroundColor(color)
        
        Spacer()
        
        // Trailing view slot (can be anything, like a toggle, chevron, etc.)
        trailingView()
    }
    .padding(.horizontal)
    .frame(width: 350, height: 60)
    .background {
        // Rounded rectangle with stroke and shadow to create a card-like effect
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 3)
    }
    // Execute the provided function when the row is tapped (if function exists)
    .onTapGesture {
        if let function = function {
            function()
        }
    }
}
