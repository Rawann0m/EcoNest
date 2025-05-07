//
//  CustomTabBar.swift
//  EcoNest
//
//  Created by Tahani Ayman on 07/11/1446 AH.
//

import SwiftUI

/// A custom tab bar view that includes a curved shape and highlights the middle tab.
struct CustomTabBar: View {
    
    @Binding var selectedIndex: Int // Tracks the currently selected tab index
    
    private let screenWidth = UIApplication.shared.screenWidth // Retrieves screen width
    
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        
        // Calculate icon height relative to screen width (responsive design)
        let iconH: CGFloat = screenWidth * (200 / 1000)
        
        ZStack {
            
            // Draws the background shape using a custom Bezier curve
            BezierCurvePath()
                .foregroundStyle(.white)
                .shadow(radius: 10)
            
            HStack(spacing: 0) {
                
                // Loop through each tab index
                ForEach(0..<Tab.allCases.count, id: \.self) { index in
                    
                    let tab = Tab.allCases[index]
                    let isSelected = selectedIndex == index + 1
                    let isMiddle = index == Tab.allCases.count / 2
                    
                    Button {
                        // Animate tab selection
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                            selectedIndex = index + 1
                        }
                    } label: {
                        VStack(spacing: 2) {
                            
                            // Tab icon
                            Image(systemName: tab.systemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .aspectRatio(isMiddle ? 0.5 : 0.7, contentMode: .fit)
                                .frame(width: isMiddle ? iconH : 35, height: isMiddle ? iconH : 35)
                                .background {
                                    if isMiddle {
                                        // Highlight background circle for middle tab
                                        Circle()
                                            .fill(.white)
                                            .shadow(radius: 10)
                                                  
                                    }
                                }
                                .offset(y: isMiddle ? -iconH / 2 : 0) // Elevate middle icon
                            
                            // Show label for non-middle tabs only
                            if !isMiddle {
                                Text(tab.rawValue.localized(using: currentLanguage))
                                    .font(.caption)
                                    .fontDesign(.rounded)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(isSelected ? Color("DarkGreen") : .gray)
                        .offset(y: !isMiddle ? -5 : 0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: iconH)
    }
}


/// A custom shape using Bezier curves to form a dip for the center tab button.
struct BezierCurvePath: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Reference dimensions from the design file (used for scaling)
        let maxW: CGFloat = 1000
        let maxH: CGFloat = 200
        
        let itemW = rect.width
        let itemH: CGFloat = itemW * (maxH / maxW) // Scale height proportionally
        
        // Start path from the top-right dip point
        path.move(to: CGPoint(x: itemW * (688.57 / maxW), y: 0))
        
        // Series of curves to form the dip in the middle
        path.addCurve(
            to: CGPoint(x: itemW * (602.09 / maxW), y: itemH * (53.06 / maxH)),
            control1: CGPoint(x: itemW * (652.05 / maxW), y: 0),
            control2: CGPoint(x: itemW * (618.97 / maxW), y: itemH * (20.68 / maxH))
        )
        path.addCurve(
            to: CGPoint(x: itemW * (580.5 / maxW), y: itemH * (82.13 / maxH)),
            control1: CGPoint(x: itemW * (596.56 / maxW), y: itemH * (63.68 / maxH)),
            control2: CGPoint(x: itemW * (589.31 / maxW), y: itemH * (73.48 / maxH))
        )
        path.addCurve(
            to: CGPoint(x: itemW * (501.13 / maxW), y: itemH * (114.99 / maxH)),
            control1: CGPoint(x: itemW * (559.33 / maxW), y: itemH * (102.88 / maxH)),
            control2: CGPoint(x: itemW * (530.77 / maxW), y: itemH * (114.71 / maxH))
        )
        path.addCurve(
            to: CGPoint(x: itemW * (418.68 / maxW), y: itemH * (81.32 / maxH)),
            control1: CGPoint(x: itemW * (469.99 / maxW), y: itemH * (115.29 / maxH)),
            control2: CGPoint(x: itemW * (440.67 / maxW), y: itemH * (103.31 / maxH))
        )
        path.addCurve(
            to: CGPoint(x: itemW * (397.52 / maxW), y: itemH * (52.3 / maxH)),
            control1: CGPoint(x: itemW * (410.03 / maxW), y: itemH * (72.67 / maxH)),
            control2: CGPoint(x: itemW * (402.93 / maxW), y: itemH * (62.88 / maxH))
        )
        path.addCurve(
            to: CGPoint(x: itemW * (311.44 / maxW), y: 0),
            control1: CGPoint(x: itemW * (381.02 / maxW), y: itemH * (20.07 / maxH)),
            control2: CGPoint(x: itemW * (347.64 / maxW), y: 0)
        )
        
        // Complete bottom rectangle shape
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: itemH))
        path.addLine(to: CGPoint(x: itemW, y: itemH))
        path.addLine(to: CGPoint(x: itemW, y: 0))
        path.addLine(to: CGPoint(x: itemW * (688.57 / maxW), y: 0))
        
        path.closeSubpath()
        return path
    }
}


