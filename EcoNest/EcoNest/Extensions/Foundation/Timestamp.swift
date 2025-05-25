//
//  Timestamp.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 11/11/1446 AH.
//

import FirebaseFirestore

/// Extension to Firebase's `Timestamp` to provide a user-friendly
/// string representing how long ago the timestamp occurred.
extension Timestamp {
    
    /// Returns a formatted string indicating the elapsed time since the timestamp.
    /// Examples: "5 seconds ago", "2 minutes ago", "3 hours ago", "4 days ago",
    /// or a date string like "21-05-2025" if more than a week ago.
    ///
    /// - Returns: A `String` representing the relative time ago.
    func timeAgoDisplay() -> String {
        let date = self.dateValue()       // Convert Timestamp to Date
        let now = Date()                  // Current date/time
        let secondsAgo = Int(now.timeIntervalSince(date))  // Seconds elapsed since the timestamp
        
        // Define time intervals in seconds
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day

        // Determine the appropriate string based on elapsed seconds
        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        } else {
            // For timestamps older than a week, show a date in "dd-MM-yyyy" format
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            return formatter.string(from: date)
        }
    }
}

