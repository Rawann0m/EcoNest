//
//  CustomRoundedRectangle.swift
//  EcoNest
//
//  Created by Rawan on 06/05/2025.
//
import SwiftUI

// MARK: - CustomRoundedRectangle

/// A custom shape that allows individually rounded corners.
struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0

    /// Creates a path for the shape in the given rectangle.
    ///
    /// - Parameter rect: The rectangle in which to draw the shape.
    /// - Returns: A `Path` representing the custom rounded rectangle.
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Ensure radii don't exceed half the size of the rectangle
        let tr = min(min(self.topRight, h / 2), w / 2)
        let tl = min(min(self.topLeft, h / 2), w / 2)
        let bl = min(min(self.bottomLeft, h / 2), w / 2)
        let br = min(min(self.bottomRight, h / 2), w / 2)

        path.move(to: CGPoint(x: tl, y: 0))

        // Top edge
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)

        // Right edge
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        // Bottom edge
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        return path
    }
}
