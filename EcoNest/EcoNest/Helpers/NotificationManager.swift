//
//  NotificationManager.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 17/11/1446 AH.
//


import SwiftUI
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager() // Singleton
    
    // Check the request permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("Notifications already authorized.")
                completion(true)
            case .notDetermined:
                let options: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            print("Permission granted")
                            completion(true)
                        } else {
                            print("Permission denied")
                            completion(false)
                        }
                    }
                }
            case .denied:
                print("Permission previously denied. Prompting user to enable from settings.")
                DispatchQueue.main.async {
                    completion(false)
                }
            case .ephemeral:
                print("Missing")
                completion(false)
            default:
                completion(false)
            }
        }
    }
    // Schedule notifications to be send every month
    func scheduleNotification(title: String, body: String, delay: TimeInterval = 5, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        // Extract day, hour, and minute from the provided Date
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 11
        dateComponents.minute = 46

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    
    // Remove all notifications if user turned off his notification
    func removeAllPendingNotifications() {
         UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
         print("All scheduled notifications removed.")
     }
    
}
