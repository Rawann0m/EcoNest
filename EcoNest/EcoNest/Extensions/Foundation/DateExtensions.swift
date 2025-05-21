//
//  DateExtensions.swift
//  EcoNest
//
//  Created by Tahani Ayman on 22/11/1446 AH.
//

import Foundation

extension Date {
    func formattedAsOrderDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g. 20 May 2025
        return formatter.string(from: self)
    }
}
