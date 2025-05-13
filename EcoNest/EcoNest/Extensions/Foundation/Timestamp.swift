//
//  Timestamp.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 11/11/1446 AH.
//

import FirebaseFirestore

extension Timestamp {
    func timeAgoDisplay() -> String {
        let date = self.dateValue()
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(date))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day

        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            return formatter.string(from: date)
        }
    }
}
