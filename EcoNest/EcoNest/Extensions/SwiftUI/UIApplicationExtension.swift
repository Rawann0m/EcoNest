//
//  UIApplicationExtension.swift
//  EcoNest
//
//  Created by Tahani Ayman on 08/11/1446 AH.
//

import SwiftUI

extension UIApplication {
    
    /// Returns the current key window (main app window)
    var keyWindow: UIWindow {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
        ?? UIWindow()
    }
    
    /// Screen width of the current device
    var screenWidth: CGFloat {
        keyWindow.bounds.size.width
    }
    
    /// Screen height of the current device
    var screenHeight: CGFloat {
        keyWindow.bounds.size.height
    }
}

