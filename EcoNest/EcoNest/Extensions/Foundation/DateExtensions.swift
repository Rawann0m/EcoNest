//
//  DateExtensions.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import Foundation

/// Extending the Date class to add custom formatting functionality
extension Date {
    
    /// Formats the date instance into a string formatted as "day month year"
    func formattedAsOrderDate() -> String {
        // Create a DateFormatter instance
        let formatter = DateFormatter()
        
        // Set the desired date format
        formatter.dateFormat = "d MMMM yyyy"
        
        // Convert the Date to a formatted String and return it
        return formatter.string(from: self)
    }
}

