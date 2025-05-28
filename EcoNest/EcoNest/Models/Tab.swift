//
//  Tab.swift
//  EcoNest
//
//  Created by Tahani Ayman on 07/11/1446 AH.
//

import Foundation

/// Represents the different tabs available in the app's custom tab bar.
enum Tab: String, CaseIterable {
    
    case home = "Home"
    case plant = "Plant"
    case module = "Module"
    case community = "Community"
    case setting = "Setting"
    
    /// Returns the corresponding SF Symbol name for each tab
    var systemImage: String {
        
        switch self {
        case .home:
            return "house"
        case .plant:
            return "apple.meditate"
        case .module:
            return "camera.viewfinder"
        case .community:
            return "person.2"
        case .setting:
            return "gearshape"
        }
    }
}
