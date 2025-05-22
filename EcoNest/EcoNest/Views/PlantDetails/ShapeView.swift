//
//  ShapeView.swift
//  EcoNest
//
//  Created by Abdullah Hafiz on 21/05/2025.
//

import SwiftUICore


struct ShapeView: View {
    var usedWaterAmount: CGFloat // Amount of budget used
    var maxWaterAmount: CGFloat // Total budget
    var color: Color
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geometry in
                // Get the width and height dynamically
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Calculate usage and remaining as a percentage
                let usagePercentage = usedWaterAmount / maxWaterAmount
                let usedPercentage = 1 - usagePercentage
                
                ZStack {
                    // Background Circle with shadow
                    Circle()
                        .fill(Color.white)
                        .frame(width: width, height: height)
                        .shadow(color: Color.gray.opacity(0.4), radius: 10, x: 0, y: 4)
                    
                    // Outer Stroke
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                        .frame(width: width, height: height)
                    
                    // Water Fill (WaveShape)
                    Circle()
                        .clipShape(
                            WaveShape(
                                waveHeight: 20, // How high the wave rises/falls
                                waveWidth: width / 3, // fit approximately 3 full waves across the shape’s width
                                fillPercentage: usedPercentage,
                                width: width,
                                height: height
                            )
                        )
                        .foregroundColor( // Change wave color based on usage
                            color
                        )
                        .frame(width: width, height: height)
                        .animation(.easeInOut(duration: 0.5), value: usagePercentage)
                    
                    // Percentage Text
                    VStack {
                        Image(systemName: icon)
                            .resizable()
                            .frame(width: icon == "drop.fill" ? 15 : 30, height: icon == "drop.fill" ? 25 : 30)
                        Text("\(maxWaterAmount == 0 ? 0 : Int(usagePercentage * 100))%")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.black)
                            .shadow(color: .white.opacity(0.8), radius: 4)
                    }
                }
            }
            .frame(width: 100, height: 100)
        }
        .padding()
    }
}

/// A custom wave shape used to fill inside the circle.
struct WaveShape: Shape {
    var waveHeight: CGFloat // Vertical size of wave
    var waveWidth: CGFloat // Horizontal length of wave
    var fillPercentage: CGFloat // How much of the circle should be filled
    var width: CGFloat // Total width of the wave area
    var height: CGFloat // Total height of the wave area
    
    var animatableData: CGFloat {
        get { fillPercentage }
        set { fillPercentage = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path() // Initialize an empty path object to begin drawing the wave shape
        
        // Calculate how high the water level should be
        let waterHeight = (fillPercentage) * height
        
        // Start at the left edge at the water height
        path.move(to: CGPoint(x:0 , y: waterHeight))
        
        // Loop across the width and draw curves
        for x in stride(from: 0, to: width, by: waveWidth) {
            let x1 = x + waveWidth / 2
            let y1 = waterHeight - waveHeight // Peak of the wave
            let x2 = x + waveWidth / 2
            let y2 = waterHeight + waveHeight // Bottom of the wave
            let x3 = x + waveWidth // End X of one wave segment
            
            // Add a smooth Bézier wave curve
            path.addCurve(
                to: CGPoint(x: x3, y: waterHeight), // End point of the curve
                control1: CGPoint(x: x1, y: y1),// Guide the curve from the left
                control2: CGPoint(x: x2, y: y2) // Guide the curve towards the right
            )
        }
        
        // Close the bottom of the wave area by drawing straight lines to the bottom corners of the shape
        path.addLine(to: CGPoint(x: width, y: height))  // Draw line to bottom right corner
        path.addLine(to: CGPoint(x: 0, y: height)) // Draw line to bottom left corner
        path.closeSubpath()
        
        return path
    }
}
